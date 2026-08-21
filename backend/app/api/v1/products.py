from fastapi import APIRouter, status

from app.api.dependencies import CurrentUserDependency, DatabaseSession
from app.schemas.product import ProductCreate, ProductCreateResponse
from app.services.product_service import ProductService

router = APIRouter()
product_service = ProductService()


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
    product = await product_service.create_product(
        session=session,
        seller_id=current_user.id,
        data=data,
    )

    return ProductCreateResponse.model_validate(product)
