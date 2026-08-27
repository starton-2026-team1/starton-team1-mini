"""add auction buy now price and extension count

Revision ID: b7f34ae52961
Revises: 80a03b071b3e
Create Date: 2026-08-21
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "b7f34ae52961"
down_revision: str | None = "80a03b071b3e"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "auctions",
        sa.Column("buy_now_price", sa.BigInteger(), nullable=True),
    )
    op.add_column(
        "auctions",
        sa.Column("extension_count", sa.Integer(), nullable=True),
    )
    op.create_check_constraint(
        "ck_auctions_buy_now_price_above_start",
        "auctions",
        "buy_now_price IS NULL OR buy_now_price > start_price",
    )
    op.create_check_constraint(
        "ck_auctions_extension_count_non_negative",
        "auctions",
        "extension_count IS NULL OR extension_count >= 0",
    )


def downgrade() -> None:
    op.drop_constraint(
        "ck_auctions_extension_count_non_negative",
        "auctions",
        type_="check",
    )
    op.drop_constraint(
        "ck_auctions_buy_now_price_above_start",
        "auctions",
        type_="check",
    )
    op.drop_column("auctions", "extension_count")
    op.drop_column("auctions", "buy_now_price")
