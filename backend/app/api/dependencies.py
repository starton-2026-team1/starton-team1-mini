from typing import Annotated

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.repositories.user_repository import UserRepository
from app.services.user_service import UserService

DatabaseSession = Annotated[
    AsyncSession,
    Depends(get_db_session),
]


def get_user_service(
    session: DatabaseSession,
) -> UserService:
    repository = UserRepository(session)
    return UserService(repository)


UserServiceDependency = Annotated[
    UserService,
    Depends(get_user_service),
]
