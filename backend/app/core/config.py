from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Starton API"
    database_url: str
    access_token_expire_minutes: int = Field(default=30, gt=0)
    refresh_token_expire_days: int = Field(default=14, gt=0)
    jwt_secret_key: str = Field(min_length=32)
    jwt_algorithm: str = "HS256"
    # 경매 상품 이미지가 저장되는 로컬 디렉터리 (main.py의 /static/uploads 마운트와 짝)
    upload_dir: str = "uploads"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
