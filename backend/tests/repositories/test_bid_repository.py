from collections.abc import AsyncIterator

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.repositories.bid_repository import BidRepository


@pytest.fixture
async def session() -> AsyncIterator[AsyncSession]:
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as connection:
        await connection.exec_driver_sql(
            """
            CREATE TABLE bids (
                id BIGINT PRIMARY KEY,
                auction_id BIGINT NOT NULL,
                bidder_id BIGINT NOT NULL,
                amount BIGINT NOT NULL,
                created_at DATETIME NOT NULL
            )
            """,
        )
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        yield session
    await engine.dispose()


async def test_get_highest_bid_returns_amount_and_bidder(session: AsyncSession) -> None:
    await session.execute(
        text(
            """
            INSERT INTO bids (id, auction_id, bidder_id, amount, created_at)
            VALUES
                (1, 3, 7, 10000, '2026-08-24 10:00:00'),
                (2, 3, 8, 15000, '2026-08-24 10:02:00'),
                (3, 4, 9, 20000, '2026-08-24 10:03:00')
            """,
        ),
    )

    bid = await BidRepository().get_highest_bid(session, auction_id=3)

    assert bid is not None
    assert bid.amount == 15000
    assert bid.bidder_id == 8


async def test_get_highest_bid_prefers_earliest_bid_when_amounts_match(
    session: AsyncSession,
) -> None:
    await session.execute(
        text(
            """
            INSERT INTO bids (id, auction_id, bidder_id, amount, created_at)
            VALUES
                (10, 5, 11, 30000, '2026-08-24 10:01:00'),
                (9, 5, 12, 30000, '2026-08-24 10:00:00')
            """,
        ),
    )

    bid = await BidRepository().get_highest_bid(session, auction_id=5)

    assert bid is not None
    assert bid.id == 9
    assert bid.bidder_id == 12


async def test_get_highest_bid_returns_none_without_bids(session: AsyncSession) -> None:
    bid = await BidRepository().get_highest_bid(session, auction_id=99)

    assert bid is None
