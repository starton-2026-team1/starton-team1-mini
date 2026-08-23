from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status

from app.api.dependencies import CurrentUserDependency, DatabaseSession
from app.core.exceptions import (
    AuctionNotFoundError,
    AuctionPermissionError,
    AuctionStateError,
    BidAmountError,
)
from app.models.enums import AuctionStatus
from app.schemas.auction import AuctionDetailResponse, AuctionPreviewListResponse
from app.schemas.bid import AuctionBroadcastMessage, BidCreate
from app.services.auction_service import AuctionService

router = APIRouter()
auction_service = AuctionService()


# 경매 도메인 예외를 HTTP 에러로 변환 (경매 없음 404, 본인 입찰 403, 상태/금액 409)
def bid_error(error: Exception) -> HTTPException:
    if isinstance(error, AuctionNotFoundError):
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(error))
    if isinstance(error, AuctionPermissionError):
        return HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(error))
    return HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(error))


# 경매 목록 조회 (상태 필터 + 페이지네이션)
@router.get("", response_model=AuctionPreviewListResponse)
async def list_auctions(
    session: DatabaseSession,
    auction_status: Annotated[AuctionStatus | None, Query(alias="status")] = None,
    offset: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
) -> AuctionPreviewListResponse:
    items, total = await auction_service.list_auctions(
        session,
        status=auction_status,
        offset=offset,
        limit=limit,
    )
    return AuctionPreviewListResponse(
        items=items,
        total=total,
        offset=offset,
        limit=limit,
    )


# 경매 상세 조회 (전체 입찰 내역 포함)
@router.get("/{auction_id}", response_model=AuctionDetailResponse)
async def get_auction(
    auction_id: int,
    session: DatabaseSession,
) -> AuctionDetailResponse:
    try:
        return await auction_service.get_detail(session, auction_id)
    except AuctionNotFoundError as error:
        raise bid_error(error) from error


# 입찰 등록 -> 검증/저장 후 웹소켓으로 실시간 브로드캐스트까지 처리됨
@router.post(
    "/{auction_id}/bids",
    response_model=AuctionBroadcastMessage,
    status_code=status.HTTP_201_CREATED,
)
async def create_bid(
    auction_id: int,
    data: BidCreate,
    session: DatabaseSession,
    current_user: CurrentUserDependency,
) -> AuctionBroadcastMessage:
    try:
        return await auction_service.place_bid(
            session,
            auction_id=auction_id,
            bidder_id=current_user.id,
            amount=data.amount,
        )
    except (
        AuctionNotFoundError,
        AuctionPermissionError,
        AuctionStateError,
        BidAmountError,
    ) as error:
        raise bid_error(error) from error
