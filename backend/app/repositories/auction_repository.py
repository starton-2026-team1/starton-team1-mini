from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.auction import Auction
from app.models.enums import AuctionStatus
from app.models.product import Product


class AuctionRepository:
    # 입찰 검증용 (상품/카테고리 등은 필요 없어서 가볍게 조회)
    async def get_by_id(
        self,
        session: AsyncSession,
        auction_id: int,
    ) -> Auction | None:
        return await session.get(Auction, auction_id)

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

    # 목록 화면용 - 페이지네이션 + 총 개수까지 같이 반환
    async def list_auctions(
        self,
        session: AsyncSession,
        *,
        status: AuctionStatus | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[Auction], int]:
        filters = []
        if status is not None:
            filters.append(Auction.status == status)

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
