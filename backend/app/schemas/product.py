from datetime import datetime
from enum import StrEnum
from typing import Annotated, Literal

from pydantic import (
    AliasPath,
    BaseModel,
    ConfigDict,
    Field,
    StringConstraints,
    computed_field,
    model_validator,
)

from app.models.enums import AuctionStatus, ProductStatus, SaleType
from app.schemas.types import UtcDateTime

ProductTitle = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=100,
    ),
]

ProductDescription = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
    ),
]


class ProductCreate(BaseModel):
    category_id: int = Field(gt=0)
    sale_type: Literal[SaleType.FIXED_PRICE] = SaleType.FIXED_PRICE
    title: ProductTitle
    description: ProductDescription
    price: int = Field(gt=0)


class ProductUpdate(BaseModel):
    category_id: int | None = Field(default=None, gt=0)
    title: ProductTitle | None = None
    description: ProductDescription | None = None
    price: int | None = Field(default=None, gt=0)

    @model_validator(mode="after")
    def require_update_value(self) -> "ProductUpdate":
        if all(value is None for value in self.model_dump().values()):
            raise ValueError("수정할 값을 한 개 이상 입력해 주세요.")
        return self


class ProductStatusUpdate(BaseModel):
    status: ProductStatus


class FixedPriceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    price: int = Field(gt=0)


class ProductImageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    image_url: str


class ProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int = Field(gt=0)
    seller_id: int = Field(gt=0)
    category_id: int = Field(gt=0)
    sale_type: SaleType
    title: str
    description: str
    status: ProductStatus
    created_at: UtcDateTime
    updated_at: UtcDateTime


class ProductDetailResponse(ProductResponse):
    fixed_price: FixedPriceResponse
    seller_name: str = Field(validation_alias=AliasPath("seller", "name"))
    images: list[ProductImageResponse] = Field(exclude=True)

    @computed_field
    @property
    def image_urls(self) -> list[str]:
        return [image.image_url for image in self.images]


class ProductCreateResponse(ProductDetailResponse):
    pass


class ProductListResponse(BaseModel):
    items: list[ProductDetailResponse]
    total: int = Field(ge=0)
    offset: int = Field(ge=0)
    limit: int = Field(ge=1, le=100)


class SalesManagementStatus(StrEnum):
    AUCTION = "AUCTION"
    SELLING = "SELLING"
    COMPLETED = "COMPLETED"


class SalesManagementProductResponse(BaseModel):
    id: int = Field(gt=0)
    auction_id: int | None = Field(default=None, gt=0)
    sale_type: SaleType
    title: str
    description: str
    product_status: ProductStatus
    management_status: SalesManagementStatus
    auction_status: AuctionStatus | None = None
    thumbnail_url: str | None = None
    price: int = Field(gt=0)
    bid_count: int = Field(default=0, ge=0)
    starts_at: datetime | None = None
    ends_at: datetime | None = None
    created_at: UtcDateTime

    @model_validator(mode="after")
    def validate_sale_details(self) -> "SalesManagementProductResponse":
        auction_fields = (
            self.auction_id,
            self.auction_status,
            self.starts_at,
            self.ends_at,
        )
        if self.sale_type == SaleType.AUCTION and any(
            value is None for value in auction_fields
        ):
            raise ValueError("경매 상품 정보가 모두 필요합니다.")
        if self.sale_type == SaleType.FIXED_PRICE and any(
            value is not None for value in auction_fields
        ):
            raise ValueError("일반 판매 상품에는 경매 정보를 포함할 수 없습니다.")
        return self


class SalesManagementProductListResponse(BaseModel):
    items: list[SalesManagementProductResponse]
    total: int = Field(ge=0)
    offset: int = Field(ge=0)
    limit: int = Field(ge=1, le=100)
