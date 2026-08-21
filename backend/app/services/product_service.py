from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import (
    ProductNotFoundError,
    ProductPermissionError,
    ProductStateError,
)
from app.models.enums import ProductStatus, SaleType
from app.models.product import Product
from app.repositories.product_repository import ProductRepository
from app.schemas.product import ProductCreate, ProductUpdate


class ProductService:
    def __init__(self, repository: ProductRepository | None = None) -> None:
        self.repository = repository or ProductRepository()

    async def create_product(
        self,
        session: AsyncSession,
        seller_id: int,
        data: ProductCreate,
    ) -> Product:
        if data.sale_type != SaleType.FIXED_PRICE:
            raise ProductStateError("현재는 일반 판매 상품만 등록할 수 있습니다.")

        return await self.repository.create_fixed_price_product(
            session=session,
            seller_id=seller_id,
            data=data,
        )

    async def list_products(
        self,
        session: AsyncSession,
        *,
        seller_id: int | None = None,
        category_id: int | None = None,
        status: ProductStatus | None = None,
        search: str | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[Product], int]:
        return await self.repository.list_products(
            session,
            seller_id=seller_id,
            category_id=category_id,
            status=status,
            search=search,
            offset=offset,
            limit=limit,
        )

    async def get_product(self, session: AsyncSession, product_id: int) -> Product:
        product = await self.repository.get_by_id(session, product_id)
        if product is None or product.sale_type != SaleType.FIXED_PRICE:
            raise ProductNotFoundError("상품을 찾을 수 없습니다.")
        return product

    async def update_product(
        self,
        session: AsyncSession,
        product_id: int,
        seller_id: int,
        data: ProductUpdate,
    ) -> Product:
        product = await self.get_product(session, product_id)
        self._validate_owner(product, seller_id)
        self._validate_editable(product)
        return await self.repository.update_fixed_price_product(session, product, data)

    async def update_product_status(
        self,
        session: AsyncSession,
        product_id: int,
        seller_id: int,
        status: ProductStatus,
    ) -> Product:
        product = await self.get_product(session, product_id)
        self._validate_owner(product, seller_id)
        if product.status == ProductStatus.SOLD:
            raise ProductStateError("거래 완료된 상품의 상태는 변경할 수 없습니다.")
        return await self.repository.update_status(session, product, status)

    async def delete_product(
        self,
        session: AsyncSession,
        product_id: int,
        seller_id: int,
    ) -> None:
        product = await self.get_product(session, product_id)
        self._validate_owner(product, seller_id)
        self._validate_editable(product)
        await self.repository.delete(session, product)

    @staticmethod
    def _validate_owner(product: Product, seller_id: int) -> None:
        if product.seller_id != seller_id:
            raise ProductPermissionError("상품 판매자만 변경할 수 있습니다.")

    @staticmethod
    def _validate_editable(product: Product) -> None:
        if product.status == ProductStatus.SOLD:
            raise ProductStateError("거래 완료된 상품은 수정하거나 삭제할 수 없습니다.")
