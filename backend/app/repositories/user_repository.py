from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User


class UserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_id(self, user_id: int) -> User | None:
        return await self.session.get(User, user_id)

    async def get_by_phone_number(self, phone_number: str) -> User | None:
        result = await self.session.execute(
            select(User).where(User.phone_number == phone_number),
        )
        return result.scalar_one_or_none()

    async def create(
            self,
            phone_number: str,
            name: str = "사용자",
    ) -> User:
        user = User(
            phone_number=phone_number,
            name=name,
        )
        self.session.add(user)
        await self.session.flush()
        return user

    async def get_or_create_by_phone_number(
            self,
            phone_number: str,
    ) -> User:
        user = await self.get_by_phone_number(phone_number)
        if user is not None:
            return user

        return await self.create(phone_number)