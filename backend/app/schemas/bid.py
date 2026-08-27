from typing import Literal

from pydantic import BaseModel, Field

from app.models.enums import AuctionStatus
from app.schemas.types import KstDateTime


# 입찰 등록 요청 (POST /auctions/{id}/bids)
class BidCreate(BaseModel):
    amount: int = Field(gt=0)


class BidResponse(BaseModel):
    bidder_name: str
    amount: int = Field(gt=0)
    created_at: KstDateTime


# 웹소켓으로 나가는 실시간 브로드캐스트 메시지 스펙 (프론트 AuctionUpdateMessage와 1:1 매칭)
class AuctionBroadcastMessage(BaseModel):
    type: Literal["bid_update"] = "bid_update"
    current_price: int
    next_bid_price: int
    ends_at: KstDateTime
    remaining_extension_count: int = Field(ge=0)
    latest_bid: BidResponse


class MyBidAuctionResponse(BaseModel):
    auction_id: int = Field(gt=0)
    title: str
    thumbnail_url: str | None
    status: AuctionStatus
    my_highest_bid: int = Field(gt=0)
    current_price: int = Field(gt=0)
    bid_count: int = Field(ge=1)
    is_highest_bidder: bool
    is_winner: bool
    ends_at: KstDateTime
    last_bid_at: KstDateTime


class MyBidAuctionListResponse(BaseModel):
    items: list[MyBidAuctionResponse]
    total: int = Field(ge=0)
    offset: int = Field(ge=0)
    limit: int = Field(ge=1, le=100)
