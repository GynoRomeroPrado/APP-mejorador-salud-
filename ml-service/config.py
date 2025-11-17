"""Configuración del microservicio ML."""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Configuración de la aplicación."""

    # Servidor
    port: int = 8001
    host: str = "0.0.0.0"
    environment: str = "development"
    debug: bool = True

    # Supabase
    supabase_url: str
    supabase_service_role_key: str

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # JWT
    jwt_secret: str
    jwt_algorithm: str = "HS256"

    # Sentry
    sentry_dsn: str | None = None

    # APIs externas
    exercisedb_api_key: str | None = None
    nutritionix_app_id: str | None = None
    nutritionix_app_key: str | None = None

    # ML
    model_version: str = "1.0.0"
    cache_ttl_seconds: int = 3600
    max_recommendations: int = 10
    min_confidence_score: float = 0.6

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Obtiene la configuración (singleton)."""
    return Settings()
