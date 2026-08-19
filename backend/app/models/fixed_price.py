from sqlalchemy import BigInteger, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class FixedPrice(Base):
    __tablename__ = "fixed_prices"

    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id", ondelete="CASCADE"),
        primary_key=True,
    )
    price: Mapped[int] = mapped_column(BigInteger, nullable=False)
