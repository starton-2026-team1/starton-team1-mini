"""update auction schema

Revision ID: 23b752491944
Revises: 21df784f4fc8
Create Date: 2026-08-20 12:14:34.285306
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "23b752491944"
down_revision: str | None = "21df784f4fc8"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.alter_column(
        "auctions",
        "status",
        existing_type=sa.Enum(
            "WAITING",
            "ACTIVE",
            "COMPLETED",
            "CANCELLED",
            name="auctionstatus",
        ),
        type_=sa.Enum(
            "WAITING",
            "ACTIVE",
            "COMPLETED",
            "NO_BIDS",
            "CANCELLED",
            "TRADE_COMPLETED",
            name="auctionstatus",
        ),
        existing_nullable=False,
    )

    op.create_check_constraint(
        "ck_auctions_start_price_positive",
        "auctions",
        "start_price > 0",
    )
    op.create_check_constraint(
        "ck_auctions_minimum_bid_unit_positive",
        "auctions",
        "minimum_bid_unit > 0",
    )
    op.create_check_constraint(
        "ck_auctions_ends_after_starts",
        "auctions",
        "ends_at > starts_at",
    )
    op.create_check_constraint(
        "ck_bids_amount_positive",
        "bids",
        "amount > 0",
    )
    op.create_check_constraint(
        "ck_fixed_prices_price_positive",
        "fixed_prices",
        "price > 0",
    )


def downgrade() -> None:
    op.execute(
        "UPDATE auctions SET status = 'COMPLETED' WHERE status IN ('NO_BIDS', 'TRADE_COMPLETED')"
    )


    op.drop_constraint(
        "ck_fixed_prices_price_positive",
        "fixed_prices",
        type_="check",
    )
    op.drop_constraint(
        "ck_bids_amount_positive",
        "bids",
        type_="check",
    )
    op.drop_constraint(
        "ck_auctions_ends_after_starts",
        "auctions",
        type_="check",
    )
    op.drop_constraint(
        "ck_auctions_minimum_bid_unit_positive",
        "auctions",
        type_="check",
    )
    op.drop_constraint(
        "ck_auctions_start_price_positive",
        "auctions",
        type_="check",
    )

    op.alter_column(
        "auctions",
        "status",
        existing_type=sa.Enum(
            "WAITING",
            "ACTIVE",
            "COMPLETED",
            "NO_BIDS",
            "CANCELLED",
            "TRADE_COMPLETED",
            name="auctionstatus",
        ),
        type_=sa.Enum(
            "WAITING",
            "ACTIVE",
            "COMPLETED",
            "CANCELLED",
            name="auctionstatus",
        ),
        existing_nullable=False,
    )
