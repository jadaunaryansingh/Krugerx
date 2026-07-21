import os
from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

    # Project Configurations
    PROJECT_NAME: str = "Krugerx Browser Backend"
    ENV: str = "development"
    DEBUG: bool = True
    API_V1_STR: str = "/api/v1"

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/postgres"

    # Supabase Auth & Storage
    SUPABASE_URL: str = "https://your-project.supabase.co"
    SUPABASE_KEY: str = "your-supabase-anon-key"          # publishable / anon key
    SUPABASE_SERVICE_KEY: str = "your-supabase-service-role-key"  # secret / service role key
    SUPABASE_JWT_SECRET: str = "your-supabase-jwt-secret-for-token-verification"
    SUPABASE_STORAGE_BUCKET: str = "krugerx-browser-storage"

    # Redis Configurations
    REDIS_URL: str = "redis://localhost:6379/0"

    # Celery Configurations
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"

    # AI API Keys
    OPENAI_API_KEY: Optional[str] = None
    GEMINI_API_KEY: Optional[str] = None
    ANTHROPIC_API_KEY: Optional[str] = None
    GROQ_API_KEY: Optional[str] = None
    OLLAMA_BASE_URL: str = "http://localhost:11434"

    # Search Keys
    GOOGLE_SEARCH_API_KEY: Optional[str] = None
    GOOGLE_SEARCH_CX_ID: Optional[str] = None
    BING_SEARCH_API_KEY: Optional[str] = None
    BRAVE_SEARCH_API_KEY: Optional[str] = None

    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60


# Global settings instance
settings = Settings()
