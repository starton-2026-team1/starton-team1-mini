from fastapi import APIRouter

from app.api.dependencies import DatabaseSession
from app.schemas.product import ProductCreate
from app.services.product_service import ProductService

router = APIRouter()
product_service = ProductService()


@router.post("")
async def create_product(
    data: ProductCreate,
    session: DatabaseSession,
) -> dict[str, object]:
    product = await product_service.create_product(
        session=session,
        data=data,
    )

    return {
        "id": product.id,
        "seller_id": product.seller_id,
        "category_id": product.category_id,
        "sale_type": product.sale_type,
        "title": product.title,
        "description": product.description,
        "price": data.price,
    }
