from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.bid import Bid
from app.models.user import User


class BidRepository:
    async def create(
        self,
        session: AsyncSession,
        auction_id: int,
        bidder_id: int,
        amount: int,
    ) -> Bid:
        bid = Bid(
            auction_id=auction_id,
            bidder_id=bidder_id,
            amount=amount,
        )
        session.add(bid)
        await session.flush()
        # created_at은 서버 기본값이라 flush 직후엔 비어있음 -> 바로 읽으려면 refresh 필요
        await session.refresh(bid, attribute_names=["created_at"])
        return bid

    # 현재가 계산용 (입찰이 없으면 None -> 시작가를 현재가로 사용)
    async def get_highest_amount(
        self,
        session: AsyncSession,
        auction_id: int,
    ) -> int | None:
        result = await session.execute(
            select(func.max(Bid.amount)).where(Bid.auction_id == auction_id),
        )
        return result.scalar_one_or_none()

    # 여러 경매의 입찰수/최고가를 한 번의 쿼리로 집계 (목록 화면에서 N+1 방지용)
    async def get_stats(
        self,
        session: AsyncSession,
        auction_ids: list[int],
    ) -> dict[int, tuple[int, int]]:
        if not auction_ids:
            return {}

        result = await session.execute(
            select(Bid.auction_id, func.count(Bid.id), func.max(Bid.amount))
            .where(Bid.auction_id.in_(auction_ids))
            .group_by(Bid.auction_id),
        )
        return {
            auction_id: (count, max_amount)
            for auction_id, count, max_amount in result.all()
        }

    # 상세 화면의 "전체 입찰 내역"용 - 입찰자 이름까지 조인해서 가져옴
    async def list_recent(
        self,
        session: AsyncSession,
        auction_id: int,
        limit: int = 20,
    ) -> list[tuple[Bid, str]]:
        result = await session.execute(
            select(Bid, User.name)
            .join(User, Bid.bidder_id == User.id)
            .where(Bid.auction_id == auction_id)
            .order_by(Bid.created_at.desc(), Bid.id.desc())
            .limit(limit),
        )
        return [(bid, name) for bid, name in result.all()]
