from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    app_name: str = "Smart Dental Diagnosis API"
    debug: bool = False

    # Database
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/dentist"

    # JWT
    secret_key: str = "change-me-in-production-use-openssl-rand-hex-32"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    # AI service
    ai_service_url: str = "http://localhost:8001"

    # Uploads
    upload_dir: str = "uploads"
    max_upload_mb: int = 10
    allowed_content_types: set = {"image/jpeg", "image/png", "image/webp"}

    class Config:
        env_file = ".env"
        extra = "ignore"


@lru_cache
def get_settings() -> Settings:
    return Settings()
