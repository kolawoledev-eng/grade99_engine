from __future__ import annotations

import hashlib
import hmac
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from app.features.auth.repository import AuthRepository


class AuthService:
    def __init__(self, repo: Optional[AuthRepository] = None) -> None:
        self.repo = repo or AuthRepository()

    @staticmethod
    def _hash_password(password: str) -> str:
        salt = secrets.token_bytes(16)
        digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 120000)
        return f"pbkdf2_sha256${salt.hex()}${digest.hex()}"

    @staticmethod
    def _verify_password(password: str, stored: str) -> bool:
        parts = (stored or "").split("$")
        if len(parts) != 3 or parts[0] != "pbkdf2_sha256":
            return False
        try:
            salt = bytes.fromhex(parts[1])
            expected = bytes.fromhex(parts[2])
        except ValueError:
            return False
        actual = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 120000)
        return hmac.compare_digest(actual, expected)

    @staticmethod
    def _token_hash(token: str) -> str:
        return hashlib.sha256(token.encode("utf-8")).hexdigest()

    def _make_session(self, user_id: str) -> str:
        raw_token = secrets.token_urlsafe(48)
        token_hash = self._token_hash(raw_token)
        self.repo.create_session(
            {
                "user_id": user_id,
                "session_token_hash": token_hash,
                "expires_at": (datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
            }
        )
        return raw_token

    def _resolve_access(self, user_id: str) -> Dict[str, Any]:
        active = self.repo.get_active_activation(user_id)
        return {
            "is_activated": bool(active),
            "free_question_limit": 5,
            "activation_status": "active" if active else "inactive",
            "activation_ends_at": (active or {}).get("ends_at"),
        }

    def register(
        self,
        *,
        first_name: str,
        last_name: str,
        phone: str,
        email: Optional[str],
        password: str,
    ) -> Dict[str, Any]:
        if self.repo.get_user_by_phone(phone):
            raise ValueError("Phone already exists")
        if email and self.repo.get_user_by_email(email):
            raise ValueError("Email already exists")
        full_name = f"{first_name.strip()} {last_name.strip()}".strip()
        user = self.repo.create_user(
            {
                "first_name": first_name.strip(),
                "last_name": last_name.strip(),
                "full_name": full_name or None,
                "phone": phone.strip(),
                "email": (email or "").strip().lower() or None,
                "password_hash": self._hash_password(password),
                "phone_verified": False,
                "email_verified": False,
                "is_deleted": False,
            }
        )
        token = self._make_session(user["id"])
        access = self._resolve_access(user["id"])
        return {"user": user, "token": token, "access": access}

    def login(self, *, identifier: str, password: str) -> Dict[str, Any]:
        ident = identifier.strip()
        user = self.repo.get_user_by_email(ident) if "@" in ident else self.repo.get_user_by_phone(ident)
        if not user:
            raise ValueError("Invalid credentials")
        if not self._verify_password(password, user.get("password_hash") or ""):
            raise ValueError("Invalid credentials")
        token = self._make_session(user["id"])
        self.repo.update_user_last_login(user["id"])
        access = self._resolve_access(user["id"])
        return {"user": user, "token": token, "access": access}

    def user_from_token(self, bearer_token: str) -> Optional[Dict[str, Any]]:
        token_hash = self._token_hash(bearer_token)
        session = self.repo.get_session_by_hash(token_hash)
        if not session:
            return None
        expires_at = session.get("expires_at")
        if expires_at:
            try:
                exp = datetime.fromisoformat(str(expires_at).replace("Z", "+00:00"))
                if exp <= datetime.now(timezone.utc):
                    return None
            except ValueError:
                return None
        return self.repo.get_user_by_id(session["user_id"])

    def logout(self, bearer_token: str) -> None:
        self.repo.revoke_session(self._token_hash(bearer_token))

    def delete_account(self, user_id: str, password: str) -> None:
        user = self.repo.get_user_by_id(user_id)
        if not user:
            raise ValueError("User not found")
        if not self._verify_password(password, user.get("password_hash") or ""):
            raise ValueError("Invalid credentials")
        self.repo.mark_user_deleted(user_id)
        self.repo.revoke_all_sessions_for_user(user_id)

    def activation_status(self, user_id: str) -> Dict[str, Any]:
        active = self.repo.get_active_activation(user_id)
        if not active:
            return {
                "is_activated": False,
                "status": "inactive",
                "plan_code": None,
                "plan_name": None,
                "starts_at": None,
                "ends_at": None,
            }
        plan = active.get("activation_plans") or {}
        return {
            "is_activated": True,
            "status": "active",
            "plan_code": plan.get("code"),
            "plan_name": plan.get("name"),
            "starts_at": active.get("starts_at"),
            "ends_at": active.get("ends_at"),
        }

    def access_state(self, user_id: str) -> Dict[str, Any]:
        return self._resolve_access(user_id)

    def list_plans(self) -> list[Dict[str, Any]]:
        return self.repo.list_activation_plans()

