from hashlib import sha256

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User


_NICKNAME_ADJECTIVES = (
    "능동적인",
    "쾌활한",
    "다정한",
    "용감한",
    "명랑한",
    "성실한",
    "재빠른",
    "차분한",
    "친절한",
    "호기심많은",
    "슬기로운",
    "따뜻한",
)
_NICKNAME_ANIMALS = (
    "오리",
    "소",
    "고양이",
    "강아지",
    "토끼",
    "여우",
    "수달",
    "판다",
    "다람쥐",
    "펭귄",
    "부엉이",
    "알파카",
)


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
        name: str | None = None,
    ) -> User:
        user = User(
            phone_number=phone_number,
            name=name or automatic_nickname(phone_number),
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
            # 기존 기본 닉네임 계정만 자동 닉네임으로 전환
            if user.name == "사용자":
                user.name = automatic_nickname(phone_number)
                await self.session.flush()
            return user

        return await self.create(phone_number)

    async def update_name(self, user: User, name: str) -> User:
        user.name = name
        await self.session.flush()
        return user


# 전화번호 원문을 노출하지 않고 동일 번호에 고정된 형용사·동물·숫자 조합 생성
def automatic_nickname(phone_number: str) -> str:
    digest = sha256(phone_number.encode("utf-8")).digest()
    adjective = _NICKNAME_ADJECTIVES[
        int.from_bytes(digest[:2], "big") % len(_NICKNAME_ADJECTIVES)
    ]
    animal = _NICKNAME_ANIMALS[
        int.from_bytes(digest[2:4], "big") % len(_NICKNAME_ANIMALS)
    ]
    number = int.from_bytes(digest[4:6], "big") % 100
    return f"{adjective}{animal}{number:02d}"
