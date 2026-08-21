from pydantic import BaseModel

from app.models.enums import SaleType

from pydantic import BaseModel, Field

class ProductCreate(BaseModel):
    category_id: int = Field(gt=0)
    sale_type: SaleType
    title: str = Field(min_length=1, max_length=100)
    description: str = Field(min_length=1)
    price: int = Field(gt=0)
