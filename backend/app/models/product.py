from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import (
    BigInteger,
    DateTime,
    Enum,
    FetchedValue,
    ForeignKey,
    Index,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base
from app.models.enums import ProductStatus, SaleType

if TYPE_CHECKING:
    from app.models.auction import Auction
    from app.models.category import Category
    from app.models.fixed_price import FixedPrice
    from app.models.product_image import ProductImage
    from app.models.user import User


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
        server_onupdate=FetchedValue(),
    )

    seller: Mapped["User"] = relationship(
        back_populates="products",
    )

    category: Mapped["Category"] = relationship(
        back_populates="products",
    )

    images: Mapped[list["ProductImage"]] = relationship(
        back_populates="product",
        cascade="all, delete-orphan",
        passive_deletes=True,
        order_by="ProductImage.sort_order",
    )

    fixed_price: Mapped["FixedPrice | None"] = relationship(
        back_populates="product",
        cascade="all, delete-orphan",
        passive_deletes=True,
        single_parent=True,
        lazy="selectin",
    )

    auction: Mapped["Auction | None"] = relationship(
        back_populates="product",
        cascade="all, delete-orphan",
        passive_deletes=True,
        single_parent=True,
    )

