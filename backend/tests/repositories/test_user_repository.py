import re
from unittest.mock import AsyncMock, MagicMock

from app.models.user import User
from app.repositories.user_repository import UserRepository, automatic_nickname


def test_automatic_nickname_is_stable_and_does_not_include_phone_number() -> None:
    first = automatic_nickname("01012345678")
    second = automatic_nickname("01012345678")

    assert first == second
    assert "01012345678" not in first
    assert first != "사용자"
    assert re.search(r"\d{2}$", first)


async def test_create_assigns_automatic_nickname() -> None:
    session = AsyncMock()
    session.add = MagicMock()
    repository = UserRepository(session)

    user = await repository.create("01012345678")

    assert user.name == automatic_nickname("01012345678")
    session.add.assert_called_once_with(user)
    session.flush.assert_awaited_once()


async def test_existing_default_name_changes_on_next_login() -> None:
    session = AsyncMock()
    result = MagicMock()
    user = User(id=1, phone_number="01012345678", name="사용자")
    result.scalar_one_or_none.return_value = user
    session.execute.return_value = result
    repository = UserRepository(session)

    found = await repository.get_or_create_by_phone_number("01012345678")

    assert found is user
    assert user.name == automatic_nickname("01012345678")
    session.flush.assert_awaited_once()


async def test_user_selected_name_is_preserved_on_login() -> None:
    session = AsyncMock()
    result = MagicMock()
    user = User(id=1, phone_number="01012345678", name="내닉네임")
    result.scalar_one_or_none.return_value = user
    session.execute.return_value = result
    repository = UserRepository(session)

    found = await repository.get_or_create_by_phone_number("01012345678")

    assert found.name == "내닉네임"
    session.flush.assert_not_awaited()
