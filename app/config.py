from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    anthropic_api_key: str
    anthropic_model: str
    supabase_url: str
    supabase_service_key: str
    supabase_anon_key: str
    app_name: str = "grade99"
    app_version: str = "1.0.0"
    # Comma-separated browser origins (Flutter web). Empty => ["*"] with credentials=False.
    cors_allowed_origins: str = ""
    # When origins are explicit: true only if you need credentialed cross-origin requests.
    cors_allow_credentials: str = ""
    # GET /api/admin/stats requires matching X-Admin-Key. Empty => endpoint disabled (503).
    admin_api_key: str = ""
    # Canonical syllabus year for JAMB classroom / aligned clients (env CURRENT_SYLLABUS_YEAR).
    current_syllabus_year: int = 2026
    # If set, POST ensure-summary / ensure-topic-page require header X-Generate-Key (same value).
    public_generate_key: str = ""
    flutterwave_secret_key: str = ""
    flutterwave_secret_hash: str = ""
    flutterwave_redirect_url: str = ""

    @property
    def supabase_key(self) -> str:
        # Service key preferred for backend server use.
        return self.supabase_service_key or self.supabase_anon_key

    def cors_middleware_options(self) -> tuple[list[str], bool]:
        raw = self.cors_allowed_origins.strip()
        if not raw:
            return (["*"], False)
        origins = [x.strip() for x in raw.split(",") if x.strip()]
        if not origins:
            return (["*"], False)
        env = self.cors_allow_credentials.strip().lower()
        if env in ("true", "1", "yes"):
            creds = True
        elif env in ("false", "0", "no"):
            creds = False
        else:
            creds = False
        return (origins, creds)


def get_settings() -> Settings:
    return Settings(
        anthropic_api_key=os.getenv("ANTHROPIC_API_KEY", ""),
        anthropic_model=os.getenv("ANTHROPIC_MODEL", "claude-3-5-sonnet-latest"),
        supabase_url=os.getenv("SUPABASE_URL", ""),
        supabase_service_key=os.getenv("SUPABASE_SERVICE_KEY", ""),
        supabase_anon_key=os.getenv("SUPABASE_ANON_KEY", ""),
        cors_allowed_origins=os.getenv("CORS_ALLOWED_ORIGINS", ""),
        cors_allow_credentials=os.getenv("CORS_ALLOW_CREDENTIALS", ""),
        admin_api_key=os.getenv("ADMIN_API_KEY", ""),
        current_syllabus_year=int(os.getenv("CURRENT_SYLLABUS_YEAR", "2026")),
        public_generate_key=os.getenv("PUBLIC_GENERATE_KEY", ""),
        flutterwave_secret_key=os.getenv("FLUTTERWAVE_SECRET_KEY", ""),
        flutterwave_secret_hash=os.getenv("FLUTTERWAVE_SECRET_HASH", ""),
        flutterwave_redirect_url=os.getenv("FLUTTERWAVE_REDIRECT_URL", ""),
    )


def validate_settings(settings: Settings) -> None:
    missing = []
    if not settings.anthropic_api_key:
        missing.append("ANTHROPIC_API_KEY")
    if not settings.supabase_url:
        missing.append("SUPABASE_URL")
    if not settings.supabase_key:
        missing.append("SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY")
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

