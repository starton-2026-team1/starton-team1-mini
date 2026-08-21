from unittest.mock import AsyncMock

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import (
    ProductNotFoundError,
    ProductPermissionError,
    ProductStateError,
)
from app.models.enums import ProductStatus, SaleType
from app.models.fixed_price import FixedPrice
from app.models.product import Product
from app.repositories.product_repository import ProductRepository
from app.schemas.product import ProductUpdate
from app.services.product_service import ProductService


def make_product(
    *,
    seller_id: int = 1,
    status: ProductStatus = ProductStatus.ACTIVE,
) -> Product:
    return Product(
        id=10,
        seller_id=seller_id,
        category_id=1,
        sale_type=SaleType.FIXED_PRICE,
        title="자전거",
        description="상태가 좋아요.",
        status=status,
        fixed_price=FixedPrice(price=30_000),
    )


@pytest.fixture
def repository() -> AsyncMock:
    return AsyncMock(spec=ProductRepository)


@pytest.fixture
def session() -> AsyncMock:
    return AsyncMock(spec=AsyncSession)


async def test_get_product_raises_when_product_does_not_exist(
    repository: AsyncMock,
    session: AsyncMock,
) -> None:
    repository.get_by_id.return_value = None
    service = ProductService(repository)

    with pytest.raises(ProductNotFoundError):
        await service.get_product(session, 99)


async def test_only_seller_can_update_product(
    repository: AsyncMock,
    session: AsyncMock,
) -> None:
    repository.get_by_id.return_value = make_product(seller_id=1)
    service = ProductService(repository)

    with pytest.raises(ProductPermissionError):
        await service.update_product(
            session,
            product_id=10,
            seller_id=2,
            data=ProductUpdate(title="수정한 제목"),
        )

    repository.update_fixed_price_product.assert_not_awaited()


async def test_sold_product_cannot_be_updated(
    repository: AsyncMock,
    session: AsyncMock,
) -> None:
    repository.get_by_id.return_value = make_product(status=ProductStatus.SOLD)
    service = ProductService(repository)

    with pytest.raises(ProductStateError):
        await service.update_product(
            session,
            product_id=10,
            seller_id=1,
            data=ProductUpdate(price=50_000),
        )

    repository.update_fixed_price_product.assert_not_awaited()


async def test_sold_product_cannot_be_deleted(
    repository: AsyncMock,
    session: AsyncMock,
) -> None:
    repository.get_by_id.return_value = make_product(status=ProductStatus.SOLD)
    service = ProductService(repository)

    with pytest.raises(ProductStateError):
        await service.delete_product(session, product_id=10, seller_id=1)

    repository.delete.assert_not_awaited()


async def test_active_product_can_be_updated(
    repository: AsyncMock,
    session: AsyncMock,
) -> None:
    product = make_product()
    updated = make_product()
    updated.title = "수정한 제목"
    repository.get_by_id.return_value = product
    repository.update_fixed_price_product.return_value = updated
    service = ProductService(repository)
    data = ProductUpdate(title="수정한 제목")

    result = await service.update_product(session, 10, 1, data)

    assert result.title == "수정한 제목"
    repository.update_fixed_price_product.assert_awaited_once_with(
        session,
        product,
        data,
    )
