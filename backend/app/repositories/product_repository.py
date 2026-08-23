from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.auction import Auction
from app.models.enums import ProductStatus, SaleType
from app.models.fixed_price import FixedPrice
from app.models.product import Product
from app.models.product_image import ProductImage
from app.schemas.auction import AuctionCreate
from app.schemas.product import ProductCreate, ProductUpdate


class ProductRepository:
    async def create_fixed_price_product(
        self,
        session: AsyncSession,
        data: ProductCreate,
        seller_id: int,
        image_urls: list[str]
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
             images=[
                ProductImage(image_url=url, sort_order=index)
                for index, url in enumerate(image_urls)],
        )

        session.add(product)
        await session.flush()
        # created_at/updated_at은 서버 기본값이라 flush 직후엔 비어있음 -> 응답 조립 전에 채워둠
        await session.refresh(
            product, 
            attribute_names=["created_at", "updated_at"])

        return product

    # 상품 + 경매 + 이미지 레코드를 한 트랜잭션에서 같이 생성
    async def create_auction_product(
        self,
        session: AsyncSession,
        data: AuctionCreate,
        seller_id: int,
        image_urls: list[str],
    ) -> Product:
        product = Product(
            seller_id=seller_id,
            category_id=data.category_id,
            sale_type=SaleType.AUCTION,
            title=data.title,
            description=data.description,
            auction=Auction(
                start_price=data.start_price,
                minimum_bid_unit=data.minimum_bid_unit,
                starts_at=data.starts_at,
                ends_at=data.ends_at,
                extension_count=data.extension_count,
            ),
            images=[
                ProductImage(image_url=url, sort_order=index)
                for index, url in enumerate(image_urls)
            ],
        )

        session.add(product)
        await session.flush()
        # created_at/updated_at은 서버 기본값이라 flush 직후엔 비어있음 -> 응답 조립 전에 채워둠
        # (관계 필드까지 통째로 refresh하면 images/auction이 다시 만료돼서 컬럼만 지정)
        await session.refresh(product, attribute_names=["created_at", "updated_at"])

        # 생성된 상품을 fixed_price와 함께 다시 조회
        result = await session.execute(
            select(Product)
            .where(Product.id == product.id)
            .options(selectinload(Product.fixed_price))
            .execution_options(populate_existing=True)
        )

        created_product = result.scalar_one()

        return created_product

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
        filters = [
            Product.sale_type == SaleType.FIXED_PRICE
        ]

        if seller_id is not None:
            filters.append(
                Product.seller_id == seller_id
            )

        if category_id is not None:
            filters.append(
                Product.category_id == category_id
            )

        if status is not None:
            filters.append(
                Product.status == status
            )

        if search:
            filters.append(
                Product.title.ilike(f"%{search.strip()}%")
            )

        products_result = await session.execute(
            select(Product)
            .where(*filters)
            .options(
                selectinload(Product.fixed_price)
            )
            .order_by(
                Product.created_at.desc(),
                Product.id.desc(),
            )
            .offset(offset)
            .limit(limit),
        )

        total_result = await session.execute(
            select(func.count(Product.id))
            .where(*filters),
        )

        return (
            list(products_result.scalars().all()),
            int(total_result.scalar_one()),
        )

    async def list_sales_management_products(
        self,
        session: AsyncSession,
        *,
        seller_id: int,
        status: ProductStatus | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[Product], int]:
        filters = [Product.seller_id == seller_id]
        if status is not None:
            filters.append(Product.status == status)
        products_result = await session.execute(
            select(Product)
            .where(*filters)
            .options(
                selectinload(Product.fixed_price),
                selectinload(Product.auction),
                selectinload(Product.images),
            )
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
            .options(
                selectinload(Product.fixed_price)
            ),
        )

        return result.scalar_one_or_none()

    async def update_fixed_price_product(
        self,
        session: AsyncSession,
        product: Product,
        data: ProductUpdate,
    ) -> Product:
        values = data.model_dump(
            exclude_none=True
        )

        price = values.pop(
            "price",
            None,
        )

        for field, value in values.items():
            setattr(
                product,
                field,
                value,
            )

        if (
            price is not None
            and product.fixed_price is not None
        ):
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

    async def delete(
        self,
        session: AsyncSession,
        product: Product,
    ) -> None:
        await session.delete(product)
        await session.flush()