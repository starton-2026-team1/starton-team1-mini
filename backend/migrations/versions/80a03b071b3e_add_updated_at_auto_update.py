"""add updated at auto update

Revision ID: 80a03b071b3e
Revises: 23b752491944
"""

from collections.abc import Sequence

from alembic import op

revision: str = "80a03b071b3e"
down_revision: str | None = "23b752491944"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute(
        "ALTER TABLE users "
        "MODIFY updated_at DATETIME NOT NULL "
        "DEFAULT CURRENT_TIMESTAMP "
        "ON UPDATE CURRENT_TIMESTAMP"
    )

    op.execute(
        "ALTER TABLE products "
        "MODIFY updated_at DATETIME NOT NULL "
        "DEFAULT CURRENT_TIMESTAMP "
        "ON UPDATE CURRENT_TIMESTAMP"
    )


def downgrade() -> None:
    op.execute("ALTER TABLE users MODIFY updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP")

    op.execute("ALTER TABLE products MODIFY updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP")
