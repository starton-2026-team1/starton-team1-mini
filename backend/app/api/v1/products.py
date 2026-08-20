from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.schemas.product import ProductCreate
from app.services.product_service import ProductService


router = APIRouter()
product_service = ProductService()


@router.post("")
async def create_product(
    data: ProductCreate,
    session: AsyncSession = Depends(get_db_session),
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