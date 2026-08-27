"""add marketplace schema

Revision ID: 21df784f4fc8
Revises: 5b976c5f8e24
Create Date: 2026-08-19
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "21df784f4fc8"
down_revision: str | None = "5b976c5f8e24"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Create the marketplace tables and extend users for phone authentication."""
    user_columns = {column["name"] for column in sa.inspect(op.get_bind()).get_columns("users")}
    if "phone_number" not in user_columns:
        op.alter_column(
            "users",
            "id",
            existing_type=sa.Integer(),
            type_=sa.BigInteger(),
            existing_nullable=False,
            autoincrement=True,
        )
        op.alter_column(
            "users",
            "name",
            existing_type=sa.String(length=100),
            type_=sa.String(length=50),
            existing_nullable=False,
        )
        op.add_column("users", sa.Column("phone_number", sa.String(length=20), nullable=False))
        op.add_column("users", sa.Column("phone_verified_at", sa.DateTime(), nullable=True))
        op.add_column(
            "users",
            sa.Column(
                "created_at",
                sa.DateTime(),
                server_default=sa.text("CURRENT_TIMESTAMP"),
                nullable=False,
            ),
        )
        op.add_column(
            "users",
            sa.Column(
                "updated_at",
                sa.DateTime(),
                server_default=sa.text("CURRENT_TIMESTAMP"),
                nullable=False,
            ),
        )
        op.create_unique_constraint("uq_users_phone_number", "users", ["phone_number"])

    op.create_table(
        "categories",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("parent_id", sa.BigInteger(), nullable=True),
        sa.Column("name", sa.String(length=50), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["parent_id"], ["categories.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name", name="uq_categories_name"),
    )
    op.create_table(
        "products",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("seller_id", sa.BigInteger(), nullable=False),
        sa.Column("category_id", sa.BigInteger(), nullable=False),
        sa.Column("sale_type", sa.Enum("FIXED_PRICE", "AUCTION", name="saletype"), nullable=False),
        sa.Column("title", sa.String(length=100), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column(
            "status",
            sa.Enum("ACTIVE", "SOLD", "CANCELLED", name="productstatus"),
            nullable=False,
        ),
        sa.Column(
            "created_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False
        ),
        sa.Column(
            "updated_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False
        ),
        sa.ForeignKeyConstraint(["category_id"], ["categories.id"]),
        sa.ForeignKeyConstraint(["seller_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_products_category_status_created",
        "products",
        ["category_id", "status", "created_at"],
    )
    op.create_index(
        "ix_products_sale_type_status_created",
        "products",
        ["sale_type", "status", "created_at"],
    )
    op.create_table(
        "fixed_prices",
        sa.Column("product_id", sa.BigInteger(), nullable=False),
        sa.Column("price", sa.BigInteger(), nullable=False),
        sa.ForeignKeyConstraint(["product_id"], ["products.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("product_id"),
    )
    op.create_table(
        "auctions",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("product_id", sa.BigInteger(), nullable=False),
        sa.Column("winner_id", sa.BigInteger(), nullable=True),
        sa.Column("start_price", sa.BigInteger(), nullable=False),
        sa.Column("minimum_bid_unit", sa.BigInteger(), nullable=False),
        sa.Column("starts_at", sa.DateTime(), nullable=False),
        sa.Column("ends_at", sa.DateTime(), nullable=False),
        sa.Column(
            "status",
            sa.Enum("WAITING", "ACTIVE", "COMPLETED", "CANCELLED", name="auctionstatus"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["product_id"], ["products.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["winner_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("product_id", name="uq_auctions_product_id"),
    )
    op.create_index("ix_auctions_status_ends", "auctions", ["status", "ends_at"])
    op.create_table(
        "bids",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("auction_id", sa.BigInteger(), nullable=False),
        sa.Column("bidder_id", sa.BigInteger(), nullable=False),
        sa.Column("amount", sa.BigInteger(), nullable=False),
        sa.Column(
            "created_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False
        ),
        sa.ForeignKeyConstraint(["auction_id"], ["auctions.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["bidder_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_bids_auction_amount", "bids", ["auction_id", "amount"])
    op.create_index("ix_bids_bidder_created", "bids", ["bidder_id", "created_at"])
    op.create_table(
        "product_images",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("product_id", sa.BigInteger(), nullable=False),
        sa.Column("image_url", sa.String(length=500), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column(
            "created_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False
        ),
        sa.ForeignKeyConstraint(["product_id"], ["products.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("product_id", "sort_order", name="uq_product_images_order"),
    )
    op.create_table(
        "favorites",
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("product_id", sa.BigInteger(), nullable=False),
        sa.Column(
            "created_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False
        ),
        sa.ForeignKeyConstraint(["product_id"], ["products.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("user_id", "product_id"),
    )


def downgrade() -> None:
    """Remove the marketplace tables and phone-authentication fields."""
    op.drop_table("favorites")
    op.drop_table("product_images")
    op.drop_index("ix_bids_bidder_created", table_name="bids")
    op.drop_index("ix_bids_auction_amount", table_name="bids")
    op.drop_table("bids")
    op.drop_index("ix_auctions_status_ends", table_name="auctions")
    op.drop_table("auctions")
    op.drop_table("fixed_prices")
    op.drop_index("ix_products_sale_type_status_created", table_name="products")
    op.drop_index("ix_products_category_status_created", table_name="products")
    op.drop_table("products")
    op.drop_table("categories")

    op.drop_constraint("uq_users_phone_number", "users", type_="unique")
    op.drop_column("users", "updated_at")
    op.drop_column("users", "created_at")
    op.drop_column("users", "phone_verified_at")
    op.drop_column("users", "phone_number")
    op.alter_column(
        "users",
        "name",
        existing_type=sa.String(length=50),
        type_=sa.String(length=100),
        existing_nullable=False,
    )
    op.alter_column(
        "users",
        "id",
        existing_type=sa.BigInteger(),
        type_=sa.Integer(),
        existing_nullable=False,
        autoincrement=True,
    )
