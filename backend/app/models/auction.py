from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import BigInteger, CheckConstraint, DateTime, Enum, ForeignKey, Index, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base
from app.models.enums import AuctionStatus

if TYPE_CHECKING:
    from app.models.product import Product

class Auction(Base):
    __tablename__ = "auctions"
    __table_args__ = (
        CheckConstraint(
            "start_price > 0",
            name="ck_auctions_start_price_positive",
        ),
        CheckConstraint(
            "minimum_bid_unit > 0",
            name="ck_auctions_minimum_bid_unit_positive",
        ),
        CheckConstraint(
            "ends_at > starts_at",
            name="ck_auctions_ends_after_starts",
        ),
        CheckConstraint(
            "buy_now_price IS NULL OR buy_now_price > start_price",
            name="ck_auctions_buy_now_price_above_start",
        ),
        CheckConstraint(
            "extension_count IS NULL OR extension_count >= 0",
            name="ck_auctions_extension_count_non_negative",
        ),
        Index("ix_auctions_status_ends", "status", "ends_at"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    winner_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    start_price: Mapped[int] = mapped_column(BigInteger, nullable=False)
    minimum_bid_unit: Mapped[int] = mapped_column(BigInteger, nullable=False)
    buy_now_price: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    extension_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    starts_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    ends_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    status: Mapped[AuctionStatus] = mapped_column(
        Enum(AuctionStatus),
        nullable=False,
        default=AuctionStatus.WAITING,
    )
    product: Mapped["Product"] = relationship(
        back_populates="auction",
    )