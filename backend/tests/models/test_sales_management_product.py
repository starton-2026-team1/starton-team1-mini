from datetime import datetime, timedelta

import pytest
from pydantic import ValidationError

from app.models.enums import AuctionStatus, ProductStatus, SaleType
from app.schemas.product import SalesManagementProductResponse, SalesManagementStatus


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
