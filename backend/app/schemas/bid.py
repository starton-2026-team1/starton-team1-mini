from typing import Literal

from pydantic import BaseModel, Field

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
    latest_bid: BidResponse
