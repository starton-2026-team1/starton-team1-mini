from collections.abc import AsyncIterator, Iterator
from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient

from app.api.dependencies import get_user_service
from app.core.exceptions import AuthenticationError
from app.core.security import create_access_token, decode_user_id
from app.main import app
from app.models.user import User
from app.schemas.auth import (
    RefreshTokenResponse,
    TokenResponse,
    UserSummary,
)
from app.services.user_service import UserService


def make_user() -> User:
    return User(
        id=1,
        phone_number="01012345678",
        name="당근 사용자",
    )


@pytest.fixture
def service() -> Iterator[AsyncMock]:
    mocked = AsyncMock(spec=UserService)
    app.dependency_overrides[get_user_service] = lambda: mocked
    yield mocked
    app.dependency_overrides.clear()


@pytest.fixture
async def client() -> AsyncIterator[AsyncClient]:
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as test_client:
        yield test_client


async def test_login_normalizes_phone_number(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    user = make_user()
    service.login.return_value = TokenResponse(
        access_token="access-token",
        refresh_token="refresh-token",
        user=UserSummary.model_validate(user),
    )

    response = await client.post(
        "/api/v1/auth/login",
        json={"phone_number": "010-1234-5678"},
    )

    assert response.status_code == 200
    assert response.json()["user"]["phone_number"] == "01012345678"
    service.login.assert_awaited_once_with("01012345678")


async def test_refresh_returns_new_token_pair(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    service.refresh.return_value = RefreshTokenResponse(
        access_token="new-access-token",
        refresh_token="new-refresh-token",
    )

    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": "refresh-token"},
    )

    assert response.status_code == 200
    assert response.json()["access_token"] == "new-access-token"
    assert response.json()["refresh_token"] == "new-refresh-token"


async def test_session_requires_access_token(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    response = await client.get("/api/v1/auth/session")

    assert response.status_code == 401
    assert response.json() == {"detail": "인증 토큰이 필요합니다."}
    service.authenticate.assert_not_awaited()


async def test_session_rejects_invalid_token(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    service.authenticate.side_effect = AuthenticationError(
        "유효하지 않거나 만료된 토큰입니다.",
    )

    response = await client.get(
        "/api/v1/auth/session",
        headers={"Authorization": "Bearer invalid-token"},
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "유효하지 않거나 만료된 토큰입니다."}
    assert response.headers["www-authenticate"] == "Bearer"


async def test_logout_authenticates_user(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    service.authenticate.return_value = make_user()

    response = await client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": "Bearer access-token"},
    )

    assert response.status_code == 200
    assert response.json()["message"] == "로그아웃되었습니다."
    service.authenticate.assert_awaited_once_with("access-token")


def test_access_token_can_be_decoded() -> None:
    token = create_access_token(1)

    assert decode_user_id(token, "access") == 1
