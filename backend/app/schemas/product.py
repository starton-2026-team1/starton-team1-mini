from pydantic import BaseModel

from app.models.enums import SaleType


class ProductCreate(BaseModel):
    seller_id: int
    category_id: int
    sale_type: SaleType
    title: str
    description: str
    price: int
