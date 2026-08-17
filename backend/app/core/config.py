from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Starton API"
    database_url: str = "sqlite+aiosqlite:///./starton.db"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
