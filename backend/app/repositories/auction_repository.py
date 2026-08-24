from datetime import datetime

from sqlalchemy import and_, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.time import now_kst_naive
from app.models.auction import Auction
from app.models.bid import Bid
from app.models.enums import AuctionStatus
from app.models.product import Product


class AuctionRepository:
    # 동일 경매의 동시 입찰을 직렬화하고 판매자도 확인할 수 있도록 행 잠금과 상품 조회를 함께 적용
    async def get_by_id(
        self,
        session: AsyncSession,
        auction_id: int,
    ) -> Auction | None:
        result = await session.execute(
            select(Auction)
            .where(Auction.id == auction_id)
            .options(selectinload(Auction.product))
            .with_for_update(),
        )
        return result.scalar_one_or_none()

    # 상세 화면용 - 상품/카테고리/판매자/이미지까지 한 번에 eager load
    async def get_detail(
        self,
        session: AsyncSession,
        auction_id: int,
    ) -> Auction | None:
        result = await session.execute(
            select(Auction)
            .where(Auction.id == auction_id)
            .options(
                selectinload(Auction.product).selectinload(Product.images),
                selectinload(Auction.product).selectinload(Product.category),
                selectinload(Auction.product).selectinload(Product.seller),
            ),
        )
        return result.scalar_one_or_none()

    async def list_expired_unfinalized_ids(
        self,
        session: AsyncSession,
        now: datetime,
        limit: int = 100,
    ) -> list[int]:
        result = await session.execute(
            select(Auction.id)
            .where(
                Auction.ends_at <= now,
                Auction.status.in_((AuctionStatus.WAITING, AuctionStatus.ACTIVE)),
            )
            .order_by(Auction.ends_at.asc(), Auction.id.asc())
            .limit(limit),
        )
        return list(result.scalars().all())

    # 목록 화면용 - 페이지네이션 + 총 개수까지 같이 반환
    async def list_auctions(
        self,
        session: AsyncSession,
        *,
        status: AuctionStatus | None = None,
        now: datetime | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[Auction], int]:
        filters = []
        if status is not None:
            filters.append(_status_filter(status, now or now_kst_naive()))

        result = await session.execute(
            select(Auction)
            .where(*filters)
            .options(
                selectinload(Auction.product).selectinload(Product.images),
                selectinload(Auction.product).selectinload(Product.category),
            )
            .order_by(Auction.ends_at.asc())
            .offset(offset)
            .limit(limit),
        )
        auctions = list(result.scalars().all())

        total_result = await session.execute(
            select(func.count(Auction.id)).where(*filters),
        )
        total = total_result.scalar_one()

        return auctions, total


# DB 저장 상태와 현재 시각, 입찰 존재 여부를 함께 사용해 화면의 상태 필터와 맞춤
def _status_filter(status: AuctionStatus, now: datetime):
    has_bid = select(Bid.id).where(Bid.auction_id == Auction.id).exists()
    calculated_status = Auction.status.not_in(
        (
            AuctionStatus.CANCELLED,
            AuctionStatus.NO_BIDS,
            AuctionStatus.TRADE_COMPLETED,
        ),
    )
    if status == AuctionStatus.WAITING:
        return and_(calculated_status, Auction.starts_at > now)
    if status == AuctionStatus.ACTIVE:
        return and_(
            calculated_status,
            Auction.starts_at <= now,
            Auction.ends_at > now,
        )
    if status == AuctionStatus.COMPLETED:
        return and_(calculated_status, Auction.ends_at <= now, has_bid)
    if status == AuctionStatus.NO_BIDS:
        return or_(
            Auction.status == AuctionStatus.NO_BIDS,
            and_(calculated_status, Auction.ends_at <= now, ~has_bid),
        )
    return Auction.status == status
