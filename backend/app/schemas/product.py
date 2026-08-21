from typing import Annotated, Literal

from pydantic import BaseModel, Field, StringConstraints

from app.models.enums import SaleType

ProductTitle = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=100,
    ),
]

ProductDescription = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
    ),
]


class ProductCreate(BaseModel):
    category_id: int = Field(gt=0)
    sale_type: Literal[SaleType.FIXED_PRICE] = SaleType.FIXED_PRICE
    title: ProductTitle
    description: ProductDescription
    price: int = Field(gt=0)


class ProductCreateResponse(BaseModel):
    product_id: int = Field(gt=0)
    seller_id: int = Field(gt=0)
    category_id: int = Field(gt=0)
    sale_type: SaleType
    title: str
    description: str
    price: int = Field(gt=0)