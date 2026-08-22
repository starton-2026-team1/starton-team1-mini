from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import (
    AuctionNotFoundError,
    AuctionStateError,
    BidAmountError,
)
from app.models.auction import Auction
from app.models.enums import AuctionStatus
from app.models.user import User
from app.repositories.auction_repository import AuctionRepository
from app.repositories.bid_repository import BidRepository
from app.schemas.auction import (
    AuctionBidHistoryResponse,
    AuctionDetailResponse,
    AuctionPreviewResponse,
)
from app.schemas.bid import AuctionBroadcastMessage, BidResponse
from app.services.connection_manager import ConnectionManager, connection_manager


class AuctionService:
    def __init__(
        self,
        auction_repository: AuctionRepository | None = None,
        bid_repository: BidRepository | None = None,
        manager: ConnectionManager | None = None,
    ) -> None:
        self.auction_repository = auction_repository or AuctionRepository()
        self.bid_repository = bid_repository or BidRepository()
        self.manager = manager or connection_manager

    # 입찰 검증 -> 저장 -> 웹소켓 브로드캐스트까지 한 번에 처리
    async def place_bid(
        self,
        session: AsyncSession,
        auction_id: int,
        bidder_id: int,
        amount: int,
    ) -> AuctionBroadcastMessage:
        auction = await self.auction_repository.get_by_id(session, auction_id)
        if auction is None:
            raise AuctionNotFoundError("경매를 찾을 수 없습니다.")

        # DB status 컬럼은 시작/종료 시각이 지나도 자동으로 안 바뀌므로
        # 저장된 값 대신 현재 시각 기준으로 계산한 상태를 써야 함
        now = datetime.now()
        if _effective_status(auction, now) != AuctionStatus.ACTIVE:
            raise AuctionStateError("진행 중인 경매가 아닙니다.")

        highest_amount = await self.bid_repository.get_highest_amount(
            session,
            auction_id,
        )
        current_price = highest_amount or auction.start_price
        # 아직 입찰이 없으면 시작가부터, 있으면 현재가 + 최소 단위부터 입찰 가능
        minimum_next_price = (
            auction.start_price
            if highest_amount is None
            else current_price + auction.minimum_bid_unit
        )
        if amount < minimum_next_price:
            raise BidAmountError(
                f"입찰 금액은 {minimum_next_price}원 이상이어야 합니다.",
            )

        bid = await self.bid_repository.create(
            session,
            auction_id=auction_id,
            bidder_id=bidder_id,
            amount=amount,
        )
        latest_bid = BidResponse(
            bidder_name=_mask_name(await self._bidder_name(session, bidder_id)),
            amount=bid.amount,
            created_at=bid.created_at,
        )
        message = AuctionBroadcastMessage(
            current_price=amount,
            next_bid_price=amount + auction.minimum_bid_unit,
            latest_bid=latest_bid,
        )

        # 이 경매를 보고 있는 모든 클라이언트(입찰자 본인 포함)에게 실시간 반영
        await self.manager.broadcast(auction_id, message)
        return message

    async def _bidder_name(self, session: AsyncSession, bidder_id: int) -> str:
        user = await session.get(User, bidder_id)
        return user.name if user is not None else "알 수 없음"

    # 경매 목록 응답 조립 (경매별 입찰수/최고가는 한 번에 집계해서 N+1 방지)
    async def list_auctions(
        self,
        session: AsyncSession,
        *,
        status: AuctionStatus | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[AuctionPreviewResponse], int]:
        auctions, total = await self.auction_repository.list_auctions(
            session,
            status=status,
            offset=offset,
            limit=limit,
        )
        stats = await self.bid_repository.get_stats(
            session,
            [auction.id for auction in auctions],
        )
        items = [
            self._to_preview(auction, stats.get(auction.id))
            for auction in auctions
        ]
        return items, total

    # 경매 상세 + 전체 입찰 내역 조립
    async def get_detail(
        self,
        session: AsyncSession,
        auction_id: int,
    ) -> AuctionDetailResponse:
        auction = await self.auction_repository.get_detail(session, auction_id)
        if auction is None:
            raise AuctionNotFoundError("경매를 찾을 수 없습니다.")

        recent_bids = await self.bid_repository.list_recent(
            session,
            auction_id,
            limit=50,
        )
        highest_amount = recent_bids[0][0].amount if recent_bids else None
        product = auction.product
        now = datetime.now()

        return AuctionDetailResponse(
            id=auction.id,
            title=product.title,
            description=product.description,
            category_name=product.category.name,
            seller_name=product.seller.name,
            status=_effective_status(auction, now),
            image_urls=[image.image_url for image in product.images],
            start_price=auction.start_price,
            current_price=highest_amount or auction.start_price,
            minimum_bid_unit=auction.minimum_bid_unit,
            starts_at=auction.starts_at,
            ends_at=auction.ends_at,
            bids=[
                AuctionBidHistoryResponse(
                    bidder_name=_mask_name(name),
                    amount=bid.amount,
                    created_at=bid.created_at,
                )
                for bid, name in recent_bids
            ],
        )

    def _to_preview(
        self,
        auction: Auction,
        stat: tuple[int, int] | None,
    ) -> AuctionPreviewResponse:
        bid_count, highest_amount = stat or (0, None)
        product = auction.product
        thumbnail_url = product.images[0].image_url if product.images else None
        now = datetime.now()
        return AuctionPreviewResponse(
            id=auction.id,
            title=product.title,
            category_name=product.category.name,
            status=_effective_status(auction, now),
            thumbnail_url=thumbnail_url,
            start_price=auction.start_price,
            current_price=highest_amount or auction.start_price,
            minimum_bid_unit=auction.minimum_bid_unit,
            bid_count=bid_count,
            starts_at=auction.starts_at,
            ends_at=auction.ends_at,
        )


# 사람이 직접 정하는 상태(취소/유찰/거래완료)는 시간 계산으로 덮어쓰면 안 되는 값들
_TERMINAL_STATUSES = {
    AuctionStatus.CANCELLED,
    AuctionStatus.NO_BIDS,
    AuctionStatus.TRADE_COMPLETED,
}


# 별도 스케줄러 없이, 조회 시점의 starts_at/ends_at과 현재 시각을 비교해 상태를 계산
# (서버 KST 로컬시각 기준 naive datetime - UTC로 계산하면 9시간 어긋남)
def _effective_status(auction: Auction, now: datetime) -> AuctionStatus:
    if auction.status in _TERMINAL_STATUSES:
        return auction.status
    if now < auction.starts_at:
        return AuctionStatus.WAITING
    if now < auction.ends_at:
        return AuctionStatus.ACTIVE
    return AuctionStatus.COMPLETED


# 입찰자 실명 대신 "김***" 형태로 마스킹해서 내려줌
def _mask_name(name: str) -> str:
    if len(name) <= 1:
        return f"{name}***"
    return f"{name[:1]}***"
