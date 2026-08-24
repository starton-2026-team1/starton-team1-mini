from datetime import datetime

from fastapi import UploadFile
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import (
    ProductNotFoundError,
    ProductPermissionError,
    ProductStateError,
)
from app.models.enums import AuctionStatus, ProductStatus, SaleType
from app.models.product import Product
from app.repositories.bid_repository import BidRepository
from app.repositories.product_repository import ProductRepository
from app.schemas.auction import AuctionCreate
from app.schemas.product import (
    ProductCreate,
    ProductUpdate,
    SalesManagementProductResponse,
    SalesManagementStatus,
)
from app.services.image_storage import ImageStorage, image_storage


class ProductService:
    def __init__(
        self,
        repository: ProductRepository | None = None,
        images: ImageStorage | None = None,
        bid_repository: BidRepository | None = None,
    ) -> None:
        self.repository = repository or ProductRepository()
        self.images = images or image_storage
        self.bid_repository = bid_repository or BidRepository()

    async def create_product(
        self,
        session: AsyncSession,
        seller_id: int,
        data: ProductCreate,
        images: list[UploadFile],
    ) -> Product:
        if data.sale_type != SaleType.FIXED_PRICE:
            raise ProductStateError("현재는 일반 판매 상품만 등록할 수 있습니다.")
        
        if not images:
            raise ProductStateError("상품 사진을 한 장 이상 등록해 주세요.")

        image_urls = await self.images.save(images)

        return await self.repository.create_fixed_price_product(
            session=session,
            seller_id=seller_id,
            data=data,
            image_urls=image_urls,
        )

    # 이미지 저장 -> 상품/경매 레코드 생성 순서로 진행
    async def create_auction_product(
        self,
        session: AsyncSession,
        seller_id: int,
        data: AuctionCreate,
        images: list[UploadFile],
    ) -> Product:
        if not images:
            raise ProductStateError("상품 사진을 한 장 이상 등록해 주세요.")

        image_urls = await self.images.save(images)
        return await self.repository.create_auction_product(
            session=session,
            seller_id=seller_id,
            data=data,
            image_urls=image_urls,
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

    async def list_sales_management_products(
        self,
        session: AsyncSession,
        *,
        seller_id: int,
        status: ProductStatus | None = None,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[SalesManagementProductResponse], int]:
        products, total = await self.repository.list_sales_management_products(
            session,
            seller_id=seller_id,
            status=status,
            offset=offset,
            limit=limit,
        )
        auction_ids = [
            product.auction.id
            for product in products
            if product.auction is not None
        ]
        bid_stats = await self.bid_repository.get_stats(session, auction_ids)
        items = [
            self._to_sales_management_product(
                product,
                bid_stats.get(product.auction.id) if product.auction is not None else None,
            )
            for product in products
        ]
        return items, total

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

    @staticmethod
    def _to_sales_management_product(
        product: Product,
        bid_stat: tuple[int, int] | None,
    ) -> SalesManagementProductResponse:
        thumbnail_url = product.images[0].image_url if product.images else None
        if product.auction is None:
            if product.fixed_price is None:
                raise ProductStateError("상품의 판매 가격 정보가 없습니다.")
            return SalesManagementProductResponse(
                id=product.id,
                sale_type=product.sale_type,
                title=product.title,
                description=product.description,
                product_status=product.status,
                management_status=(
                    SalesManagementStatus.SELLING
                    if product.status == ProductStatus.ACTIVE
                    else SalesManagementStatus.COMPLETED
                ),
                thumbnail_url=thumbnail_url,
                price=product.fixed_price.price,
                created_at=product.created_at,
            )

        bid_count, highest_amount = bid_stat or (0, None)
        auction = product.auction
        auction_status = ProductService._effective_auction_status(
            auction.status,
            auction.starts_at,
            auction.ends_at,
        )
        return SalesManagementProductResponse(
            id=product.id,
            auction_id=auction.id,
            sale_type=product.sale_type,
            title=product.title,
            description=product.description,
            product_status=product.status,
            management_status=ProductService._sales_management_status(
                product.status,
                auction_status,
            ),
            auction_status=auction_status,
            thumbnail_url=thumbnail_url,
            price=highest_amount or auction.start_price,
            bid_count=bid_count,
            starts_at=auction.starts_at,
            ends_at=auction.ends_at,
            created_at=product.created_at,
        )

    @staticmethod
    def _effective_auction_status(
        status: AuctionStatus,
        starts_at: datetime,
        ends_at: datetime,
    ) -> AuctionStatus:
        if status in {
            AuctionStatus.CANCELLED,
            AuctionStatus.NO_BIDS,
            AuctionStatus.TRADE_COMPLETED,
        }:
            return status
        now = datetime.now()
        if now < starts_at:
            return AuctionStatus.WAITING
        if now < ends_at:
            return AuctionStatus.ACTIVE
        return AuctionStatus.COMPLETED

    @staticmethod
    def _sales_management_status(
        product_status: ProductStatus,
        auction_status: AuctionStatus,
    ) -> SalesManagementStatus:
        if product_status != ProductStatus.ACTIVE:
            return SalesManagementStatus.COMPLETED
        if auction_status in {AuctionStatus.WAITING, AuctionStatus.ACTIVE}:
            return SalesManagementStatus.AUCTION
        return SalesManagementStatus.COMPLETED
