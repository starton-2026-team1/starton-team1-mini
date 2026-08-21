from collections.abc import AsyncIterator, Iterator
from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient

from app.api.dependencies import get_user_service
from app.main import app
from app.models.user import User
from app.services.user_service import UserService


def make_user(name: str = '당근 사용자') -> User:
    return User(id=1, phone_number='01012345678', name=name)


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
        base_url='http://test',
    ) as test_client:
        yield test_client


async def test_update_my_name(client: AsyncClient, service: AsyncMock) -> None:
    current_user = make_user()
    updated_user = make_user('김주')
    service.authenticate.return_value = current_user
    service.update_name.return_value = updated_user

    response = await client.patch(
        '/api/v1/users/me',
        headers={'Authorization': 'Bearer access-token'},
        json={'name': '김주'},
    )

    assert response.status_code == 200
    assert response.json() == {'id': 1, 'name': '김주'}
    service.update_name.assert_awaited_once_with(current_user, '김주')


async def test_update_my_name_requires_authentication(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    response = await client.patch('/api/v1/users/me', json={'name': '김주'})

    assert response.status_code == 401
    service.update_name.assert_not_awaited()


async def test_update_my_name_rejects_empty_name(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    response = await client.patch(
        '/api/v1/users/me',
        headers={'Authorization': 'Bearer access-token'},
        json={'name': ''},
    )

    assert response.status_code == 422
    service.update_name.assert_not_awaited()


async def test_update_my_name_rejects_whitespace_name(
    client: AsyncClient,
    service: AsyncMock,
) -> None:
    response = await client.patch(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer access-token"},
        json={"name": "   "},
    )

    assert response.status_code == 422
    service.update_name.assert_not_awaited()
