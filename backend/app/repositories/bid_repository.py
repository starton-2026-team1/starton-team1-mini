from dataclasses import dataclass
from datetime import datetime

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.time import now_kst_naive
from app.models.auction import Auction
from app.models.bid import Bid
from app.models.product import Product
from app.models.user import User


@dataclass(frozen=True)
class BidParticipation:
    auction: Auction
    my_highest_bid: int
    current_price: int
    bid_count: int
    last_bid_at: datetime


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
            # DB 서버 시간대와 무관하게 경매 시간과 동일한 KST naive 값으로 저장
            created_at=now_kst_naive(),
        )
        session.add(bid)
        await session.flush()
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

    async def get_highest_bid(
        self,
        session: AsyncSession,
        auction_id: int,
    ) -> Bid | None:
        result = await session.execute(
            select(Bid)
            .where(Bid.auction_id == auction_id)
            .order_by(
                Bid.amount.desc(),
                Bid.created_at.asc(),
                Bid.id.asc(),
            )
            .limit(1),
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

    # 참여한 경매별 내 최고 입찰가와 전체 입찰 현황 조회
    async def list_by_bidder(
        self,
        session: AsyncSession,
        bidder_id: int,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[BidParticipation], int]:
        my_bids = (
            select(
                Bid.auction_id.label("auction_id"),
                func.max(Bid.amount).label("my_highest_bid"),
                func.max(Bid.created_at).label("last_bid_at"),
            )
            .where(Bid.bidder_id == bidder_id)
            .group_by(Bid.auction_id)
            .subquery()
        )
        bid_stats = (
            select(
                Bid.auction_id.label("auction_id"),
                func.max(Bid.amount).label("current_price"),
                func.count(Bid.id).label("bid_count"),
            )
            .group_by(Bid.auction_id)
            .subquery()
        )
        result = await session.execute(
            select(
                Auction,
                my_bids.c.my_highest_bid,
                bid_stats.c.current_price,
                bid_stats.c.bid_count,
                my_bids.c.last_bid_at,
            )
            .join(my_bids, my_bids.c.auction_id == Auction.id)
            .join(bid_stats, bid_stats.c.auction_id == Auction.id)
            .options(
                selectinload(Auction.product).selectinload(Product.images),
                selectinload(Auction.product).selectinload(Product.category),
            )
            .order_by(my_bids.c.last_bid_at.desc(), Auction.id.desc())
            .offset(offset)
            .limit(limit),
        )
        total_result = await session.execute(
            select(func.count(func.distinct(Bid.auction_id))).where(
                Bid.bidder_id == bidder_id,
            ),
        )
        items = [
            BidParticipation(
                auction=auction,
                my_highest_bid=my_highest_bid,
                current_price=current_price,
                bid_count=bid_count,
                last_bid_at=last_bid_at,
            )
            for auction, my_highest_bid, current_price, bid_count, last_bid_at in result.all()
        ]
        return items, total_result.scalar_one()
