from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.models.enums import AuctionStatus, ProductStatus
from app.schemas.product import ProductDescription, ProductTitle


# 경매 등록 요청 (POST /products/auctions 의 폼 필드와 매핑됨)
class AuctionCreate(BaseModel):
    category_id: int = Field(gt=0)
    title: ProductTitle
    description: ProductDescription
    start_price: int = Field(gt=0)
    minimum_bid_unit: int = Field(gt=0)
    starts_at: datetime
    ends_at: datetime
    extension_count: int = Field(default=0, ge=0)

    @model_validator(mode="after")
    def ends_after_starts(self) -> "AuctionCreate":
        if self.ends_at <= self.starts_at:
            raise ValueError("종료 시간은 시작 시간보다 늦어야 합니다.")
        return self


# 경매 등록 응답에 포함되는 경매 정보
class AuctionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int = Field(gt=0)
    product_id: int = Field(gt=0)
    start_price: int = Field(gt=0)
    minimum_bid_unit: int = Field(gt=0)
    extension_count: int | None
    starts_at: datetime
    ends_at: datetime
    status: AuctionStatus


class ProductImageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int = Field(gt=0)
    image_url: str
    sort_order: int


# 경매 등록(POST /products/auctions) 응답 - 상품 + 경매 + 이미지 정보를 한 번에 내려줌
class AuctionProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int = Field(gt=0)
    seller_id: int = Field(gt=0)
    category_id: int = Field(gt=0)
    title: str
    description: str
    status: ProductStatus
    created_at: datetime
    updated_at: datetime
    images: list[ProductImageResponse]
    auction: AuctionResponse


# 경매 목록 카드 하나에 필요한 정보 (썸네일, 현재가, 입찰수, 남은시간 계산용 starts_at/ends_at)
class AuctionPreviewResponse(BaseModel):
    id: int = Field(gt=0)
    title: str
    category_name: str
    status: AuctionStatus
    thumbnail_url: str | None
    start_price: int
    current_price: int
    minimum_bid_unit: int
    bid_count: int = Field(ge=0)
    starts_at: datetime
    ends_at: datetime


class AuctionPreviewListResponse(BaseModel):
    items: list[AuctionPreviewResponse]
    total: int = Field(ge=0)
    offset: int = Field(ge=0)
    limit: int = Field(ge=1, le=100)


# 상세 화면의 "전체 입찰 내역" 한 줄
class AuctionBidHistoryResponse(BaseModel):
    bidder_name: str
    amount: int
    created_at: datetime


# 경매 상세 화면 응답
class AuctionDetailResponse(BaseModel):
    id: int = Field(gt=0)
    title: str
    description: str
    category_name: str
    seller_name: str
    status: AuctionStatus
    image_urls: list[str]
    start_price: int
    current_price: int
    minimum_bid_unit: int
    starts_at: datetime
    ends_at: datetime
    bids: list[AuctionBidHistoryResponse]
