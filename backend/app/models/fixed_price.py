from sqlalchemy import BigInteger, CheckConstraint, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class FixedPrice(Base):
    __tablename__ = "fixed_prices"

    __table_args__ = (
        CheckConstraint(
            "price > 0",
            name="ck_fixed_prices_price_positive",
        ),
    )

    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id", ondelete="CASCADE"),
        primary_key=True,
    )
    price: Mapped[int] = mapped_column(BigInteger, nullable=False)
