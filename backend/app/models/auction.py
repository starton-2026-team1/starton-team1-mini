from datetime import datetime

from sqlalchemy import BigInteger, DateTime, Enum, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base
from app.models.enums import AuctionStatus


class Auction(Base):
    __tablename__ = "auctions"
    __table_args__ = (Index("ix_auctions_status_ends", "status", "ends_at"),)

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    winner_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    start_price: Mapped[int] = mapped_column(BigInteger, nullable=False)
    minimum_bid_unit: Mapped[int] = mapped_column(BigInteger, nullable=False)
    starts_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    ends_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    status: Mapped[AuctionStatus] = mapped_column(
        Enum(AuctionStatus),
        nullable=False,
        default=AuctionStatus.WAITING,
    )
