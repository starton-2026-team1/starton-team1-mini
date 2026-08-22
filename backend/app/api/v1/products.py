from datetime import datetime
from typing import Annotated

from fastapi import (
    APIRouter,
    File,
    Form,
    HTTPException,
    Query,
    Response,
    UploadFile,
    status,
)
from pydantic import ValidationError

from app.api.dependencies import CurrentUserDependency, DatabaseSession
from app.core.exceptions import (
    ProductNotFoundError,
    ProductPermissionError,
    ProductStateError,
)
from app.models.enums import ProductStatus
from app.schemas.auction import AuctionCreate, AuctionProductResponse
from app.schemas.product import (
    ProductCreate,
    ProductCreateResponse,
    ProductDetailResponse,
    ProductListResponse,
    ProductStatusUpdate,
    ProductUpdate,
)
from app.services.product_service import ProductService

router = APIRouter()
product_service = ProductService()

OffsetQuery = Annotated[int, Query(ge=0)]
LimitQuery = Annotated[int, Query(ge=1, le=100)]
ProductStatusQuery = Annotated[ProductStatus | None, Query(alias="status")]


def product_error(error: Exception) -> HTTPException:
    if isinstance(error, ProductNotFoundError):
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(error))
    if isinstance(error, ProductPermissionError):
        return HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(error))
    return HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(error))


@router.post(
    "",
    response_model=ProductCreateResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_product(
    data: ProductCreate,
    session: DatabaseSession,
    current_user: CurrentUserDependency,
) -> ProductCreateResponse:
    try:
        product = await product_service.create_product(
            session=session,
            seller_id=current_user.id,
            data=data,
        )
    except ProductStateError as error:
        raise product_error(error) from error
    return ProductCreateResponse.model_validate(product)


# 경매 상품 등록 (multipart/form-data: 폼 필드 + 이미지 파일들)
@router.post(
    "/auctions",
    response_model=AuctionProductResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_auction_product(
    session: DatabaseSession,
    current_user: CurrentUserDependency,
    category_id: Annotated[int, Form(gt=0)],
    title: Annotated[str, Form(min_length=1, max_length=100)],
    description: Annotated[str, Form(min_length=1)],
    start_price: Annotated[int, Form(gt=0)],
    minimum_bid_unit: Annotated[int, Form(gt=0)],
    starts_at: Annotated[datetime, Form()],
    ends_at: Annotated[datetime, Form()],
    images: Annotated[list[UploadFile], File()],
    extension_count: Annotated[int, Form(ge=0)] = 0,
) -> AuctionProductResponse:
    try:
        data = AuctionCreate(
            category_id=category_id,
            title=title,
            description=description,
            start_price=start_price,
            minimum_bid_unit=minimum_bid_unit,
            starts_at=starts_at,
            ends_at=ends_at,
            extension_count=extension_count,
        )
    except ValidationError as error:
        # 요청 바디가 아니라 함수 안에서 직접 만든 모델이라 FastAPI가 자동으로 422 처리를 안 해줌
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(error),
        ) from error

    try:
        product = await product_service.create_auction_product(
            session=session,
            seller_id=current_user.id,
            data=data,
            images=images,
        )
    except ProductStateError as error:
        raise product_error(error) from error
    return AuctionProductResponse.model_validate(product)


@router.get("", response_model=ProductListResponse)
async def list_products(
    session: DatabaseSession,
    category_id: Annotated[int | None, Query(gt=0)] = None,
    product_status: ProductStatusQuery = None,
    search: Annotated[str | None, Query(min_length=1, max_length=100)] = None,
    offset: OffsetQuery = 0,
    limit: LimitQuery = 20,
) -> ProductListResponse:
    products, total = await product_service.list_products(
        session,
        category_id=category_id,
        status=product_status,
        search=search,
        offset=offset,
        limit=limit,
    )
    return ProductListResponse(
        items=[ProductDetailResponse.model_validate(product) for product in products],
        total=total,
        offset=offset,
        limit=limit,
    )


@router.get("/me", response_model=ProductListResponse)
async def list_my_products(
    session: DatabaseSession,
    current_user: CurrentUserDependency,
    product_status: ProductStatusQuery = None,
    offset: OffsetQuery = 0,
    limit: LimitQuery = 20,
) -> ProductListResponse:
    products, total = await product_service.list_products(
        session,
        seller_id=current_user.id,
        status=product_status,
        offset=offset,
        limit=limit,
    )
    return ProductListResponse(
        items=[ProductDetailResponse.model_validate(product) for product in products],
        total=total,
        offset=offset,
        limit=limit,
    )


@router.get("/{product_id}", response_model=ProductDetailResponse)
async def get_product(
    product_id: int,
    session: DatabaseSession,
) -> ProductDetailResponse:
    try:
        product = await product_service.get_product(session, product_id)
    except ProductNotFoundError as error:
        raise product_error(error) from error
    return ProductDetailResponse.model_validate(product)


@router.patch("/{product_id}", response_model=ProductDetailResponse)
async def update_product(
    product_id: int,
    data: ProductUpdate,
    session: DatabaseSession,
    current_user: CurrentUserDependency,
) -> ProductDetailResponse:
    try:
        product = await product_service.update_product(
            session,
            product_id,
            current_user.id,
            data,
        )
    except (ProductNotFoundError, ProductPermissionError, ProductStateError) as error:
        raise product_error(error) from error
    return ProductDetailResponse.model_validate(product)


@router.patch("/{product_id}/status", response_model=ProductDetailResponse)
async def update_product_status(
    product_id: int,
    data: ProductStatusUpdate,
    session: DatabaseSession,
    current_user: CurrentUserDependency,
) -> ProductDetailResponse:
    try:
        product = await product_service.update_product_status(
            session,
            product_id,
            current_user.id,
            data.status,
        )
    except (ProductNotFoundError, ProductPermissionError, ProductStateError) as error:
        raise product_error(error) from error
    return ProductDetailResponse.model_validate(product)


@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: int,
    session: DatabaseSession,
    current_user: CurrentUserDependency,
) -> Response:
    try:
        await product_service.delete_product(session, product_id, current_user.id)
    except (ProductNotFoundError, ProductPermissionError, ProductStateError) as error:
        raise product_error(error) from error
    return Response(status_code=status.HTTP_204_NO_CONTENT)
