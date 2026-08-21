from sqlalchemy.ext.asyncio import AsyncSession

from app.models.fixed_price import FixedPrice
from app.models.product import Product
from app.schemas.product import ProductCreate


class ProductRepository:
    async def create_fixed_price_product(
        self,
        session: AsyncSession,
        data: ProductCreate,
        seller_id: int,
        ) -> Product:
        product = Product(
            seller_id=seller_id,
            category_id=data.category_id,
            sale_type=data.sale_type,
            title=data.title,
            description=data.description,
            fixed_price=FixedPrice(
                price=data.price,
            ),
        )

        session.add(product)
        await session.flush()

        return product
