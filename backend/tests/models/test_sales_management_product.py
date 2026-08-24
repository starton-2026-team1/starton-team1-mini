from datetime import datetime, timedelta

import pytest
from pydantic import ValidationError

from app.models.enums import AuctionStatus, ProductStatus, SaleType
from app.models.fixed_price import FixedPrice
from app.models.product import Product
from app.models.product_image import ProductImage
from app.models.user import User
from app.schemas.product import (
    ProductDetailResponse,
    SalesManagementProductResponse,
    SalesManagementStatus,
)


def response_values() -> dict[str, object]:
    now = datetime.now()
    return {
        "id": 1,
        "sale_type": SaleType.FIXED_PRICE,
        "title": "자전거",
        "product_status": ProductStatus.ACTIVE,
        "management_status": SalesManagementStatus.SELLING,
        "price": 30_000,
        "created_at": now,
    }


def test_fixed_price_response_rejects_auction_fields() -> None:
    values = response_values()
    values["auction_id"] = 7

    with pytest.raises(ValidationError):
        SalesManagementProductResponse(**values)


def test_auction_response_requires_all_auction_fields() -> None:
    values = response_values()
    values.update(
        sale_type=SaleType.AUCTION,
        management_status=SalesManagementStatus.AUCTION,
        auction_id=7,
        auction_status=AuctionStatus.ACTIVE,
        starts_at=datetime.now() - timedelta(hours=1),
    )

    with pytest.raises(ValidationError):
        SalesManagementProductResponse(**values)


def test_product_detail_response_includes_seller_name_and_image_urls() -> None:
    now = datetime.now()
    product = Product(
        id=1,
        seller_id=2,
        category_id=1,
        sale_type=SaleType.FIXED_PRICE,
        title="자전거",
        description="상태가 좋아요.",
        status=ProductStatus.ACTIVE,
        created_at=now,
        updated_at=now,
        seller=User(id=2, phone_number="01012345678", name="당근이"),
        fixed_price=FixedPrice(price=30_000),
        images=[
            ProductImage(image_url="/static/uploads/first.jpg", sort_order=0),
            ProductImage(image_url="/static/uploads/second.jpg", sort_order=1),
        ],
    )

    response = ProductDetailResponse.model_validate(product)

    assert response.model_dump()["seller_name"] == "당근이"
    assert response.model_dump()["image_urls"] == [
        "/static/uploads/first.jpg",
        "/static/uploads/second.jpg",
    ]
    assert "images" not in response.model_dump()
