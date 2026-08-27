from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.exceptions import AuthenticationError
from app.models.user import User
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

bearer_scheme = HTTPBearer(auto_error=False)

BearerCredentials = Annotated[
    HTTPAuthorizationCredentials | None,
    Depends(bearer_scheme),
]


async def get_current_user(
        credentials: BearerCredentials,
        service: UserServiceDependency,
) -> User:
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증 토큰이 필요합니다.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        return await service.authenticate(credentials.credentials)
    except AuthenticationError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


CurrentUserDependency = Annotated[
    User,
    Depends(get_current_user),
]
