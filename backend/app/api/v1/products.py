from fastapi import APIRouter

from app.api.dependencies import DatabaseSession, CurrentUserDependency
from app.schemas.product import ProductCreate
from app.services.product_service import ProductService

router = APIRouter()
product_service = ProductService()


@router.post("")
async def create_product(
    data: ProductCreate,
    session: DatabaseSession,
    current_user: CurrentUserDependency,
) -> dict[str, object]:
    product = await product_service.create_product(
        session=session,
        seller_id=current_user.id,
        data=data,
    )

    return {
        "id": product.id,
        "seller_id": product.seller_id,
        "category_id": categories_id,
        "sale_type": product.sale_type,
        "title": product.title,
        "description": product.description,
        "price": data.price,
    }
