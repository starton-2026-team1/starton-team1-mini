import re
from typing import Annotated, Any

from pydantic import (
    BaseModel,
    BeforeValidator,
    ConfigDict,
    Field,
)

from app.core.config import settings


def normalize_phone_number(value: object) -> object:
    if isinstance(value, str):
        return re.sub(r"\D", "", value)
    return value


PhoneNumber = Annotated[
    str,
    BeforeValidator(normalize_phone_number),
    Field(
        pattern=r"^010\d{8}$",
        examples=["01012345678"],
        description="번호 11자리",
    ),
]


class PhoneLoginRequest(BaseModel):
    phone_number: PhoneNumber


class UserSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int = Field(gt=0)
    phone_number: PhoneNumber
    name: str = Field(min_length=1, max_length=50)


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    access_token_expires_in: int = settings.access_token_expire_minutes * 60
    refresh_token_expires_in: int = settings.refresh_token_expire_days * 86400


class TokenResponse(TokenPair):
    user: UserSummary


class RefreshTokenRequest(BaseModel):
    refresh_token: str = Field(
        min_length=1,
        examples=["refresh-token"],
    )


class RefreshTokenResponse(TokenPair):
    pass


class SessionResponse(BaseModel):
    user: UserSummary


class ErrorResponse(BaseModel):
    code: str
    message: str
    details: dict[str, Any] | None = None
