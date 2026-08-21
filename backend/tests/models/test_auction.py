from datetime import datetime, timedelta

import pytest
from sqlalchemy import create_engine, insert
from sqlalchemy.exc import IntegrityError

from app.models import Auction, Base
from app.models.enums import AuctionStatus


@pytest.fixture
def engine():
    database_engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(database_engine)
    yield database_engine
    database_engine.dispose()


def auction_values(**overrides: int | None) -> dict[str, object]:
    starts_at = datetime(2026, 8, 22, 10)
    values: dict[str, object] = {
        "id": 1,
        "product_id": 1,
        "winner_id": None,
        "start_price": 100_000,
        "minimum_bid_unit": 5_000,
        "buy_now_price": None,
        "extension_count": None,
        "starts_at": starts_at,
        "ends_at": starts_at + timedelta(hours=1),
        "status": AuctionStatus.WAITING,
    }
    values.update(overrides)
    return values


def test_optional_auction_settings_accept_null(engine) -> None:
    with engine.begin() as connection:
        connection.execute(insert(Auction).values(**auction_values()))


@pytest.mark.parametrize(
    "overrides",
    [
        {"start_price": 0},
        {"minimum_bid_unit": 0},
        {"buy_now_price": 100_000},
        {"extension_count": -1},
    ],
)
def test_invalid_auction_prices_and_extension_count_are_rejected(
    engine,
    overrides: dict[str, int],
) -> None:
    with pytest.raises(IntegrityError), engine.begin() as connection:
        connection.execute(insert(Auction).values(**auction_values(**overrides)))


def test_buy_now_price_does_not_need_to_match_bid_unit(engine) -> None:
    with engine.begin() as connection:
        connection.execute(
            insert(Auction).values(
                **auction_values(buy_now_price=101_000, extension_count=0)
            )
        )
