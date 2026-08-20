from typing import Annotated

from fastapi import APIRouter, Depends, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from starlette.responses import JSONResponse

from app.api.dependencies import UserServiceDependency
from app.core.exceptions import AuthenticationError
from app.schemas.auth import (
    ErrorResponse,
    LogoutResponse,
    PhoneLoginRequest,
    RefreshTokenRequest,
    RefreshTokenResponse,
    SessionResponse,
    TokenResponse,
    UserSummary,
)

router = APIRouter()

bearer_scheme = HTTPBearer(auto_error=False)

BearerCredentials = Annotated[
    HTTPAuthorizationCredentials | None,
    Depends(bearer_scheme),
]

unauthorized_response = {
    "model": ErrorResponse,
    "description": "인증 실패",
}


def unauthorized(message: str) -> JSONResponse:
    error = ErrorResponse(
        code="AUTHENTICATION_FAILED",
        message=message,
    )
    return JSONResponse(
        status_code=status.HTTP_401_UNAUTHORIZED,
        content=error.model_dump(exclude_none=True),
        headers={"WWW-Authenticate": "Bearer"},
    )


@router.post(
    "/login",
    response_model=TokenResponse,
    responses={401: unauthorized_response},
)
async def login(
    request: PhoneLoginRequest,
    service: UserServiceDependency,
) -> TokenResponse | JSONResponse:
    try:
        return await service.login(request.phone_number)
    except AuthenticationError as exc:
        return unauthorized(str(exc))


@router.post(
    "/refresh",
    response_model=RefreshTokenResponse,
    responses={401: unauthorized_response},
)
async def refresh(
    request: RefreshTokenRequest,
    service: UserServiceDependency,
) -> RefreshTokenResponse | JSONResponse:
    try:
        return await service.refresh(request.refresh_token)
    except AuthenticationError as exc:
        return unauthorized(str(exc))


@router.get(
    "/session",
    response_model=SessionResponse,
    responses={401: unauthorized_response},
)
async def session(
    credentials: BearerCredentials,
    service: UserServiceDependency,
) -> SessionResponse | JSONResponse:
    if credentials is None:
        return unauthorized("인증 토큰이 필요합니다.")

    try:
        user = await service.authenticate(credentials.credentials)
    except AuthenticationError as exc:
        return unauthorized(str(exc))

    return SessionResponse(
        user=UserSummary.model_validate(user),
    )


@router.post(
    "/logout",
    response_model=LogoutResponse,
    responses={401: unauthorized_response},
)
async def logout(
    credentials: BearerCredentials,
    service: UserServiceDependency,
) -> LogoutResponse | JSONResponse:
    if credentials is None:
        return unauthorized("인증 토큰이 필요합니다.")

    try:
        await service.authenticate(credentials.credentials)
    except AuthenticationError as exc:
        return unauthorized(str(exc))

    return LogoutResponse(
        message="로그아웃되었습니다.",
    )
