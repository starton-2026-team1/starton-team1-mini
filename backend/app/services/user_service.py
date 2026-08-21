import jwt

from app.core.exceptions import AuthenticationError
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_user_id,
)
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.auth import (
    RefreshTokenResponse,
    TokenResponse,
    UserSummary,
)


class UserService:
    def __init__(self, repository: UserRepository) -> None:
        self.repository = repository

    async def login(self, phone_number: str) -> TokenResponse:
        user = await self.repository.get_or_create_by_phone_number(
            phone_number,
        )
        return self._create_login_response(user)

    async def refresh(
        self,
        refresh_token: str,
    ) -> RefreshTokenResponse:
        user_id = self._decode_token(
            refresh_token,
            expected_type="refresh",
        )
        user = await self.repository.get_by_id(user_id)

        if user is None:
            raise AuthenticationError("사용자를 찾을 수 없습니다.")

        return RefreshTokenResponse(
            access_token=create_access_token(user.id),
            refresh_token=create_refresh_token(user.id),
        )

    async def authenticate(self, access_token: str) -> User:
        user_id = self._decode_token(
            access_token,
            expected_type="access",
        )
        user = await self.repository.get_by_id(user_id)

        if user is None:
            raise AuthenticationError("사용자를 찾을 수 없습니다.")

        return user

    async def update_name(self, user: User, name: str) -> User:
        return await self.repository.update_name(user, name.strip())

    @staticmethod
    def _decode_token(
        token: str,
        expected_type: str,
    ) -> int:
        try:
            if expected_type == "access":
                return decode_user_id(token, "access")

            return decode_user_id(token, "refresh")
        except jwt.InvalidTokenError as exc:
            raise AuthenticationError(
                "유효하지 않거나 만료된 토큰입니다.",
            ) from exc

    @staticmethod
    def _create_login_response(user: User) -> TokenResponse:
        return TokenResponse(
            access_token=create_access_token(user.id),
            refresh_token=create_refresh_token(user.id),
            user=UserSummary.model_validate(user),
        )
