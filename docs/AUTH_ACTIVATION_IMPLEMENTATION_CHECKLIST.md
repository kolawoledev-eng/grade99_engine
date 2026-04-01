# Auth + Activation Implementation Checklist

This checklist is tailored to the current project layout:

- Backend API: `engine/app/...`
- SQL migrations: `engine/sql/...`
- Flutter app: `app/lib/...`

The goal is to ship:

1. Free practice cap (5 questions for non-activated users)
2. Activation paywall modal on question 6+
3. One-screen signup/login (phone required, email optional)
4. Account tab actions (logout + delete account)
5. Activation status management

---

## 0) Migration rollout

- [x] Add SQL migration: `engine/sql/021_auth_activation_paywall.sql`
- [ ] Run migration in Supabase/Postgres
- [ ] Verify tables/indexes:
  - `users` (extended)
  - `auth_sessions`
  - `activation_plans`
  - `user_activations`
  - `practice_attempts`

---

## 1) Backend API implementation plan

### 1.1 Add feature module

Create:

- `engine/app/features/auth/api/routes.py`
- `engine/app/features/auth/schemas.py`
- `engine/app/features/auth/service.py`
- `engine/app/features/auth/repository.py`

Wire router in `engine/app/main.py`:

- `from app.features.auth.api.routes import router as auth_router`
- `app.include_router(auth_router)`

### 1.2 Token/session strategy

- Use bearer token in `Authorization: Bearer <token>`
- Persist only hash in DB (`auth_sessions.session_token_hash`)
- Add auth dependency helper:
  - Suggested file: `engine/app/core/auth.py`
  - Function: `get_current_user()`

---

## 2) Exact endpoint contracts

All contracts below are concrete and can be implemented directly.

### 2.1 Register (single screen)

`POST /api/auth/register`

Request:

```json
{
  "first_name": "Ada",
  "last_name": "Lovelace",
  "phone": "+2348012345678",
  "email": "ada@example.com",
  "password": "StrongPass123!"
}
```

Rules:

- `phone` required and unique among non-deleted users
- `email` optional; if present must be unique among non-deleted users
- `password` min 8 chars

Response `201`:

```json
{
  "status": "success",
  "user": {
    "id": "uuid",
    "first_name": "Ada",
    "last_name": "Lovelace",
    "phone": "+2348012345678",
    "email": "ada@example.com",
    "activation_status": "inactive"
  },
  "token": "session_token",
  "access": {
    "is_activated": false,
    "free_question_limit": 5
  }
}
```

### 2.2 Login

`POST /api/auth/login`

Request:

```json
{
  "identifier": "+2348012345678",
  "password": "StrongPass123!"
}
```

`identifier` accepts phone or email.

Response `200`: same shape as register response.

### 2.3 Logout

`POST /api/auth/logout`

Headers:

- `Authorization: Bearer <token>`

Response `200`:

```json
{
  "status": "success"
}
```

### 2.4 Current account

`GET /api/auth/me`

Response `200`:

```json
{
  "status": "success",
  "user": {
    "id": "uuid",
    "first_name": "Ada",
    "last_name": "Lovelace",
    "phone": "+2348012345678",
    "email": "ada@example.com",
    "activation_status": "active",
    "activation_ends_at": "2026-07-01T00:00:00Z"
  }
}
```

### 2.5 Access/paywall state

`GET /api/auth/access`

Response `200`:

```json
{
  "status": "success",
  "is_activated": false,
  "free_question_limit": 5,
  "blocked_message": "Activate for unlimited access"
}
```

### 2.6 Activation plans

`GET /api/activation/plans`

Response `200`:

```json
{
  "status": "success",
  "plans": [
    { "code": "month_1", "name": "1 Month", "duration_days": 30, "price_kobo": 200000 },
    { "code": "month_3", "name": "3 Months", "duration_days": 90, "price_kobo": 300000 },
    { "code": "year_1", "name": "1 Year", "duration_days": 365, "price_kobo": 500000 }
  ]
}
```

### 2.7 Activation status

`GET /api/activation/status`

Response `200`:

```json
{
  "status": "success",
  "activation": {
    "is_activated": true,
    "status": "active",
    "plan_code": "month_1",
    "starts_at": "2026-06-01T00:00:00Z",
    "ends_at": "2026-07-01T00:00:00Z"
  }
}
```

### 2.8 Delete account

`DELETE /api/auth/account`

Request:

```json
{
  "password": "StrongPass123!"
}
```

Behavior:

- Mark `users.is_deleted = true`
- Set `deleted_at = now()`
- Revoke all `auth_sessions` for that user

Response `200`:

```json
{
  "status": "success"
}
```

---

## 3) Practice paywall enforcement

### 3.1 Backend rule (authoritative)

Update:

- `engine/app/features/practice/api/routes.py`

Inside `GET /api/practice/session`:

- Determine user from auth token (or anonymous device id header)
- If not activated:
  - `served_limit = min(limit, 5)`
  - return only first 5 questions
  - include metadata:
    - `is_activated: false`
    - `free_question_limit: 5`
    - `paywall_trigger_question: 6`

Suggested additions in response:

```json
{
  "is_activated": false,
  "free_question_limit": 5,
  "paywall_trigger_question": 6
}
```

Optional stricter mode:

- Keep current endpoint as-is for first 5 and add:
  - `GET /api/practice/question/{index}` that returns `403 ACTIVATION_REQUIRED` for index >= 6

Error contract for blocked access:

```json
{
  "detail": {
    "code": "ACTIVATION_REQUIRED",
    "title": "Activate for unlimited access",
    "message": "Please activate to unlock unlimited questions, quizzes, explanations, and new updates.",
    "free_question_limit": 5
  }
}
```

---

## 4) Flutter implementation plan

### 4.1 API client updates

Update `app/lib/api_client.dart`:

- Add typed calls:
  - `registerUser(...)`
  - `loginUser(...)`
  - `logoutUser(...)`
  - `fetchMe()`
  - `fetchAccessState()`
  - `fetchActivationPlans()`
  - `fetchActivationStatus()`
  - `deleteAccount(...)`
- Add auth header injection for bearer token.

### 4.2 Session store

Create:

- `app/lib/services/auth_session_store.dart`

Store:

- token
- user id
- first/last name
- phone/email
- activation status

### 4.3 Practice paywall modal

Update:

- `app/lib/features/practice/presentation/practice_session_screen.dart`

Behavior:

- If user reaches question index `>= 5` and `is_activated == false`, show modal:
  - Title: `Activate for unlimited access`
  - Body: `Please activate to unlock unlimited questions, quizzes, explanations, and new updates.`
  - Buttons:
    - `Activate now` -> open `ActivationTab` or onboarding
    - `Submit test` -> call `_finishSession()`

### 4.4 One-screen auth UI

Create:

- `app/lib/features/account/presentation/auth_gate_screen.dart`

Fields:

- first name
- last name
- phone (required)
- email (optional)
- password
- confirm password

Primary CTA:

- `Create account and continue`

Secondary CTA:

- `I already have an account` (switch to login mode)

### 4.5 Account + settings actions

Update:

- `app/lib/main.dart` (`AccountTab`)
- `app/lib/services/app_session.dart` (replace local-only logout behavior)

Add:

- `Log out` -> server logout + local token clear
- `Delete account` -> confirm dialog + password prompt + API call
- Activation status card in Account/Activation tab

---

## 5) Acceptance checklist

- [ ] Unactivated user receives max 5 questions in practice
- [ ] Attempt to continue beyond 5 always shows paywall modal
- [ ] Register with phone + password works
- [ ] Login with phone or email works
- [ ] `GET /api/auth/me` returns profile + activation status
- [ ] Logout invalidates session server-side
- [ ] Delete account marks user deleted and revokes sessions
- [ ] Activation tab shows plan + active/expired state
- [ ] Existing practice/classroom/literature flows remain unaffected

