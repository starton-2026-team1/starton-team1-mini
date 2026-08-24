from collections.abc import AsyncIterator
from datetime import datetime

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.repositories.auction_repository import AuctionRepository


@pytest.fixture
async def session() -> AsyncIterator[AsyncSession]:
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as connection:
        await connection.exec_driver_sql(
            """
            CREATE TABLE auctions (
                id BIGINT PRIMARY KEY,
                status VARCHAR(20) NOT NULL,
                ends_at DATETIME NOT NULL
            )
            """,
        )

    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        yield session
    await engine.dispose()


async def test_list_expired_unfinalized_ids_filters_orders_and_limits(
    session: AsyncSession,
) -> None:
    await session.execute(
        text(
            """
            INSERT INTO auctions (id, status, ends_at)
            VALUES
                (1, 'ACTIVE', '2026-08-24 09:00:00'),
                (2, 'WAITING', '2026-08-24 08:00:00'),
                (3, 'ACTIVE', '2026-08-24 11:00:00'),
                (4, 'COMPLETED', '2026-08-24 07:00:00'),
                (5, 'CANCELLED', '2026-08-24 06:00:00')
            """,
        ),
    )

    auction_ids = await AuctionRepository().list_expired_unfinalized_ids(
        session,
        now=datetime(2026, 8, 24, 10),
        limit=1,
    )

    assert auction_ids == [2]
