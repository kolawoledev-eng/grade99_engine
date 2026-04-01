from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict, Optional

from app.core.db import get_supabase_client


class AuthRepository:
    def get_user_by_phone(self, phone: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("users")
            .select("*")
            .eq("phone", phone)
            .eq("is_deleted", False)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("users")
            .select("*")
            .ilike("email", email)
            .eq("is_deleted", False)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("users")
            .select("*")
            .eq("id", user_id)
            .eq("is_deleted", False)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def create_user(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        rows = get_supabase_client().table("users").insert(payload).execute().data or []
        if not rows:
            raise ValueError("Failed to create user")
        return rows[0]

    def update_user_last_login(self, user_id: str) -> None:
        get_supabase_client().table("users").update(
            {"last_login_at": datetime.now(timezone.utc).isoformat()}
        ).eq("id", user_id).execute()

    def create_session(self, payload: Dict[str, Any]) -> None:
        get_supabase_client().table("auth_sessions").insert(payload).execute()

    def get_session_by_hash(self, token_hash: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("auth_sessions")
            .select("*")
            .eq("session_token_hash", token_hash)
            .is_("revoked_at", "null")
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def revoke_session(self, token_hash: str) -> None:
        get_supabase_client().table("auth_sessions").update(
            {"revoked_at": datetime.now(timezone.utc).isoformat()}
        ).eq("session_token_hash", token_hash).execute()

    def revoke_all_sessions_for_user(self, user_id: str) -> None:
        get_supabase_client().table("auth_sessions").update(
            {"revoked_at": datetime.now(timezone.utc).isoformat()}
        ).eq("user_id", user_id).is_("revoked_at", "null").execute()

    def mark_user_deleted(self, user_id: str) -> None:
        now = datetime.now(timezone.utc).isoformat()
        get_supabase_client().table("users").update(
            {"is_deleted": True, "deleted_at": now}
        ).eq("id", user_id).execute()

    def get_active_activation(self, user_id: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("user_activations")
            .select("status,starts_at,ends_at,activation_plans(code,name)")
            .eq("user_id", user_id)
            .eq("status", "active")
            .order("ends_at", desc=True)
            .limit(1)
            .execute()
            .data
            or []
        )
        if not rows:
            return None
        row = rows[0]
        ends_at = row.get("ends_at")
        if ends_at:
            try:
                end_dt = datetime.fromisoformat(str(ends_at).replace("Z", "+00:00"))
                if end_dt <= datetime.now(timezone.utc):
                    return None
            except ValueError:
                return None
        return row

    def list_activation_plans(self) -> list[Dict[str, Any]]:
        return (
            get_supabase_client()
            .table("activation_plans")
            .select("code,name,duration_days,price_kobo")
            .eq("is_active", True)
            .order("duration_days")
            .execute()
            .data
            or []
        )

    def get_activation_plan_by_code(self, code: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("activation_plans")
            .select("id,code,name,duration_days,price_kobo,is_active")
            .eq("code", code)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def get_activation_plan_by_id(self, plan_id: int) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("activation_plans")
            .select("id,code,name,duration_days,price_kobo,is_active")
            .eq("id", plan_id)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def create_pending_activation(self, *, user_id: str, plan_id: int, tx_ref: str) -> Dict[str, Any]:
        rows = (
            get_supabase_client()
            .table("user_activations")
            .insert(
                {
                    "user_id": user_id,
                    "plan_id": plan_id,
                    "status": "pending",
                    "provider": "flutterwave",
                    "provider_reference": tx_ref,
                }
            )
            .execute()
            .data
            or []
        )
        if not rows:
            raise ValueError("Failed to create pending activation")
        return rows[0]

    def get_activation_by_reference(self, tx_ref: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("user_activations")
            .select("id,user_id,plan_id,status,starts_at,ends_at,provider_reference")
            .eq("provider", "flutterwave")
            .eq("provider_reference", tx_ref)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def get_latest_active_activation(self, user_id: str) -> Optional[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("user_activations")
            .select("id,starts_at,ends_at,status")
            .eq("user_id", user_id)
            .eq("status", "active")
            .order("ends_at", desc=True)
            .limit(1)
            .execute()
            .data
            or []
        )
        return rows[0] if rows else None

    def expire_active_activations(self, user_id: str) -> None:
        get_supabase_client().table("user_activations").update(
            {"status": "expired", "updated_at": datetime.now(timezone.utc).isoformat()}
        ).eq("user_id", user_id).eq("status", "active").execute()

    def mark_activation_active(
        self,
        *,
        activation_id: str,
        starts_at_iso: str,
        ends_at_iso: str,
    ) -> None:
        get_supabase_client().table("user_activations").update(
            {
                "status": "active",
                "starts_at": starts_at_iso,
                "ends_at": ends_at_iso,
                "updated_at": datetime.now(timezone.utc).isoformat(),
            }
        ).eq("id", activation_id).execute()

