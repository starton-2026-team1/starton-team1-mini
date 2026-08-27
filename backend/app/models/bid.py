from datetime import datetime

from sqlalchemy import BigInteger, CheckConstraint, DateTime, ForeignKey, Index, func
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Bid(Base):
    __tablename__ = "bids"
    __table_args__ = (
        CheckConstraint(
            "amount > 0",
            name="ck_bids_amount_positive",
        ),
        Index("ix_bids_auction_amount", "auction_id", "amount"),
        Index("ix_bids_bidder_created", "bidder_id", "created_at"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    auction_id: Mapped[int] = mapped_column(
        ForeignKey("auctions.id", ondelete="CASCADE"),
        nullable=False,
    )
    bidder_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    amount: Mapped[int] = mapped_column(BigInteger, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )
