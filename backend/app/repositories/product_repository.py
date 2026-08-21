from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.enums import ProductStatus, SaleType
from app.models.fixed_price import FixedPrice
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate


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
        filters = [Product.sale_type == SaleType.FIXED_PRICE]
        if seller_id is not None:
            filters.append(Product.seller_id == seller_id)
        if category_id is not None:
            filters.append(Product.category_id == category_id)
        if status is not None:
            filters.append(Product.status == status)
        if search:
            filters.append(Product.title.ilike(f"%{search.strip()}%"))

        products_result = await session.execute(
            select(Product)
            .where(*filters)
            .options(selectinload(Product.fixed_price))
            .order_by(Product.created_at.desc(), Product.id.desc())
            .offset(offset)
            .limit(limit),
        )
        total_result = await session.execute(
            select(func.count(Product.id)).where(*filters),
        )
        return list(products_result.scalars().all()), int(total_result.scalar_one())

    async def get_by_id(
        self,
        session: AsyncSession,
        product_id: int,
    ) -> Product | None:
        result = await session.execute(
            select(Product)
            .where(Product.id == product_id)
            .options(selectinload(Product.fixed_price)),
        )
        return result.scalar_one_or_none()

    async def update_fixed_price_product(
        self,
        session: AsyncSession,
        product: Product,
        data: ProductUpdate,
    ) -> Product:
        values = data.model_dump(exclude_none=True)
        price = values.pop("price", None)
        for field, value in values.items():
            setattr(product, field, value)
        if price is not None and product.fixed_price is not None:
            product.fixed_price.price = price
        await session.flush()
        return product

    async def update_status(
        self,
        session: AsyncSession,
        product: Product,
        status: ProductStatus,
    ) -> Product:
        product.status = status
        await session.flush()
        return product

    async def delete(self, session: AsyncSession, product: Product) -> None:
        await session.delete(product)
        await session.flush()
