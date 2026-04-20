"""Users: first_name, last_name, phone (replace name)

Revision ID: 002
Revises: 001
Create Date: 2025-01-01 00:01:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "002"
down_revision: Union[str, None] = "001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("first_name", sa.String(128), nullable=True))
    op.add_column("users", sa.Column("last_name", sa.String(128), nullable=True))
    op.add_column("users", sa.Column("phone", sa.String(32), nullable=True))
    op.execute("UPDATE users SET first_name = COALESCE(name, ''), last_name = '', phone = '' WHERE first_name IS NULL")
    op.alter_column(
        "users",
        "first_name",
        existing_type=sa.String(128),
        nullable=False,
    )
    op.alter_column(
        "users",
        "last_name",
        existing_type=sa.String(128),
        nullable=False,
    )
    op.alter_column(
        "users",
        "phone",
        existing_type=sa.String(32),
        nullable=False,
    )
    op.drop_column("users", "name")


def downgrade() -> None:
    op.add_column("users", sa.Column("name", sa.String(255), nullable=True))
    op.execute("UPDATE users SET name = TRIM(first_name || ' ' || last_name) WHERE name IS NULL")
    op.alter_column("users", "name", nullable=False)
    op.drop_column("users", "first_name")
    op.drop_column("users", "last_name")
    op.drop_column("users", "phone")
