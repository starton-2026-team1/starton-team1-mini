from sqlalchemy.ext.asyncio import AsyncSession

from app.models.enums import SaleType
from app.models.product import Product
from app.repositories.product_repository import ProductRepository
from app.schemas.product import ProductCreate


class ProductService:
    def __init__(self) -> None:
        self.repository = ProductRepository()

    async def create_product(
        self,
        session: AsyncSession,
        data: ProductCreate,
    ) -> Product:
        if data.sale_type != SaleType.FIXED_PRICE:
            raise ValueError("현재는 일반 판매 상품만 등록할 수 있습니다.")

        product = await self.repository.create_fixed_price_product(
            session=session,
            data=data,
        )

        return product
