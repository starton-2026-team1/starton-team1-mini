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
        )

        session.add(product)

        # DB가 product.id를 만들어주도록 반영
        await session.flush()

        fixed_price = FixedPrice(
            product_id=product.id,
            price=data.price,
        )

        session.add(fixed_price)

        return product
