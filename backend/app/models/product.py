from datetime import datetime

from sqlalchemy import BigInteger, DateTime, Enum, ForeignKey, Index, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base
from app.models.enums import ProductStatus, SaleType


class Product(Base):
    __tablename__ = "products"
    __table_args__ = (
        Index("ix_products_category_status_created", "category_id", "status", "created_at"),
        Index("ix_products_sale_type_status_created", "sale_type", "status", "created_at"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    seller_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    category_id: Mapped[int] = mapped_column(ForeignKey("categories.id"), nullable=False)
    sale_type: Mapped[SaleType] = mapped_column(Enum(SaleType), nullable=False)
    title: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[ProductStatus] = mapped_column(
        Enum(ProductStatus),
        nullable=False,
        default=ProductStatus.ACTIVE,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )
