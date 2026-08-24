from datetime import datetime, timedelta
from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.core.exceptions import (
    AuctionNotFoundError,
    AuctionPermissionError,
    AuctionStateError,
    BidAmountError,
)
from app.models.enums import AuctionStatus
from app.repositories.auction_repository import AuctionRepository
from app.repositories.bid_repository import BidRepository
from app.services.auction_service import AuctionService, _effective_status
from app.services.connection_manager import ConnectionManager


async def test_seller_cannot_bid_on_own_auction() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    manager = AsyncMock(spec=ConnectionManager)
    now = datetime.now()
    auction_repository.get_by_id.return_value = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=7),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=1),
        ends_at=now + timedelta(hours=1),
        start_price=10000,
        minimum_bid_unit=1000,
    )
    service = AuctionService(auction_repository, bid_repository, manager)

    with pytest.raises(
        AuctionPermissionError,
        match="판매자는 자신의 경매에 입찰할 수 없습니다.",
    ):
        await service.place_bid(
            AsyncMock(),
            auction_id=3,
            bidder_id=7,
            amount=10000,
        )

    bid_repository.create.assert_not_awaited()


async def test_duplicate_bid_amount_is_rejected() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    manager = AsyncMock(spec=ConnectionManager)
    now = datetime.now()
    auction_repository.get_by_id.return_value = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=9),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=1),
        ends_at=now + timedelta(hours=1),
        start_price=10000,
        minimum_bid_unit=1000,
    )
    bid_repository.get_highest_amount.return_value = 12000
    service = AuctionService(auction_repository, bid_repository, manager)

    with pytest.raises(BidAmountError, match="13000원 이상"):
        await service.place_bid(
            AsyncMock(),
            auction_id=3,
            bidder_id=7,
            amount=12000,
        )

    bid_repository.create.assert_not_awaited()


async def test_bid_near_deadline_extends_auction_and_decreases_count() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    manager = AsyncMock(spec=ConnectionManager)
    now = datetime.now()
    auction = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=9),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=1),
        ends_at=now + timedelta(minutes=4),
        start_price=10000,
        minimum_bid_unit=1000,
        extension_count=2,
    )
    bid = SimpleNamespace(
        amount=10000,
        created_at=now,
    )
    auction_repository.get_by_id.return_value = auction
    bid_repository.get_highest_amount.return_value = None
    bid_repository.create.return_value = bid
    service = AuctionService(auction_repository, bid_repository, manager)

    original_ends_at = auction.ends_at
    response = await service.place_bid(
        AsyncMock(),
        auction_id=3,
        bidder_id=7,
        amount=10000,
    )

    assert auction.ends_at == original_ends_at + timedelta(minutes=5)
    assert auction.extension_count == 1
    assert response.ends_at == auction.ends_at
    assert response.remaining_extension_count == 1
    manager.broadcast.assert_awaited_once_with(3, response)


async def test_bid_outside_extension_window_keeps_deadline() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    manager = AsyncMock(spec=ConnectionManager)
    now = datetime.now()
    auction = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=9),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=1),
        ends_at=now + timedelta(minutes=6),
        start_price=10000,
        minimum_bid_unit=1000,
        extension_count=2,
    )
    auction_repository.get_by_id.return_value = auction
    bid_repository.get_highest_amount.return_value = None
    bid_repository.create.return_value = SimpleNamespace(
        amount=10000,
        created_at=now,
    )
    service = AuctionService(auction_repository, bid_repository, manager)

    original_ends_at = auction.ends_at
    await service.place_bid(
        AsyncMock(),
        auction_id=3,
        bidder_id=7,
        amount=10000,
    )

    assert auction.ends_at == original_ends_at
    assert auction.extension_count == 2


async def test_bid_lookup_locks_auction_row() -> None:
    session = AsyncMock()
    result = MagicMock()
    result.scalar_one_or_none.return_value = None
    session.execute.return_value = result

    await AuctionRepository().get_by_id(session, auction_id=3)

    statement = session.execute.await_args.args[0]
    assert "FOR UPDATE" in str(statement)


async def test_seller_can_cancel_auction_without_bids() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    now = datetime.now()
    auction = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=7),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=1),
        ends_at=now + timedelta(hours=1),
    )
    auction_repository.get_by_id.return_value = auction
    bid_repository.get_highest_amount.return_value = None
    session = AsyncMock()
    service = AuctionService(auction_repository, bid_repository)

    response = await service.cancel_auction(session, auction_id=3, seller_id=7)

    assert response.status == AuctionStatus.CANCELLED
    assert auction.status == AuctionStatus.CANCELLED
    session.flush.assert_awaited_once()


async def test_auction_with_bid_cannot_be_cancelled() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    now = datetime.now()
    auction_repository.get_by_id.return_value = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=7),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=1),
        ends_at=now + timedelta(hours=1),
    )
    bid_repository.get_highest_amount.return_value = 12000
    session = AsyncMock()
    service = AuctionService(auction_repository, bid_repository)

    with pytest.raises(AuctionStateError, match="입찰이 있는 경매"):
        await service.cancel_auction(session, auction_id=3, seller_id=7)

    session.flush.assert_not_awaited()


async def test_finalize_auction_stores_highest_bidder_as_winner() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    auction = SimpleNamespace(
        id=3,
        status=AuctionStatus.ACTIVE,
        ends_at=datetime.now() - timedelta(minutes=1),
        winner_id=None,
    )
    auction_repository.get_by_id.return_value = auction
    bid_repository.get_highest_bid.return_value = SimpleNamespace(bidder_id=8)
    session = AsyncMock()

    response = await AuctionService(
        auction_repository,
        bid_repository,
    ).finalize_auction(session, auction_id=3)

    assert response.status == AuctionStatus.COMPLETED
    assert auction.status == AuctionStatus.COMPLETED
    assert auction.winner_id == 8
    session.flush.assert_awaited_once()


async def test_finalize_auction_without_bids_stores_no_bids() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    auction = SimpleNamespace(
        id=3,
        status=AuctionStatus.ACTIVE,
        ends_at=datetime.now() - timedelta(minutes=1),
        winner_id=None,
    )
    auction_repository.get_by_id.return_value = auction
    bid_repository.get_highest_bid.return_value = None
    session = AsyncMock()

    response = await AuctionService(
        auction_repository,
        bid_repository,
    ).finalize_auction(session, auction_id=3)

    assert response.status == AuctionStatus.NO_BIDS
    assert auction.status == AuctionStatus.NO_BIDS
    assert auction.winner_id is None
    session.flush.assert_awaited_once()


async def test_finalize_auction_rejects_before_end() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    auction_repository.get_by_id.return_value = SimpleNamespace(
        id=3,
        status=AuctionStatus.ACTIVE,
        ends_at=datetime.now() + timedelta(minutes=1),
        winner_id=None,
    )
    session = AsyncMock()
    service = AuctionService(auction_repository, bid_repository)

    with pytest.raises(AuctionStateError, match="아직 종료되지 않은 경매"):
        await service.finalize_auction(session, auction_id=3)

    bid_repository.get_highest_bid.assert_not_awaited()
    session.flush.assert_not_awaited()


@pytest.mark.parametrize(
    "status",
    [
        AuctionStatus.COMPLETED,
        AuctionStatus.NO_BIDS,
        AuctionStatus.CANCELLED,
        AuctionStatus.TRADE_COMPLETED,
    ],
)
async def test_finalize_auction_keeps_finalized_result(status: AuctionStatus) -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    auction_repository.get_by_id.return_value = SimpleNamespace(
        id=3,
        status=status,
        ends_at=datetime.now() - timedelta(minutes=1),
        winner_id=8,
    )
    session = AsyncMock()

    response = await AuctionService(
        auction_repository,
        bid_repository,
    ).finalize_auction(session, auction_id=3)

    assert response.status == status
    bid_repository.get_highest_bid.assert_not_awaited()
    session.flush.assert_not_awaited()


async def test_finalize_auction_raises_when_auction_does_not_exist() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    auction_repository.get_by_id.return_value = None

    with pytest.raises(AuctionNotFoundError):
        await AuctionService(
            auction_repository,
            bid_repository,
        ).finalize_auction(AsyncMock(), auction_id=99)


async def test_seller_completes_trade_after_auction_end() -> None:
    auction_repository = AsyncMock(spec=AuctionRepository)
    bid_repository = AsyncMock(spec=BidRepository)
    now = datetime.now()
    auction = SimpleNamespace(
        id=3,
        product=SimpleNamespace(seller_id=7),
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=2),
        ends_at=now - timedelta(hours=1),
    )
    auction_repository.get_by_id.return_value = auction
    bid_repository.get_highest_amount.return_value = 12000
    session = AsyncMock()
    service = AuctionService(auction_repository, bid_repository)

    response = await service.complete_trade(session, auction_id=3, seller_id=7)

    assert response.status == AuctionStatus.TRADE_COMPLETED
    assert auction.status == AuctionStatus.TRADE_COMPLETED
    session.flush.assert_awaited_once()


@pytest.mark.parametrize(
    ("bid_count", "expected"),
    [
        (0, AuctionStatus.NO_BIDS),
        (1, AuctionStatus.COMPLETED),
    ],
)
def test_finished_auction_status_depends_on_bid_count(
    bid_count: int,
    expected: AuctionStatus,
) -> None:
    now = datetime.now()
    auction = SimpleNamespace(
        status=AuctionStatus.ACTIVE,
        starts_at=now - timedelta(hours=2),
        ends_at=now - timedelta(hours=1),
    )

    assert _effective_status(auction, now, bid_count=bid_count) == expected


@pytest.mark.parametrize(
    "status",
    [
        AuctionStatus.CANCELLED,
        AuctionStatus.NO_BIDS,
        AuctionStatus.TRADE_COMPLETED,
    ],
)
def test_terminal_status_is_not_overwritten(status: AuctionStatus) -> None:
    now = datetime.now()
    auction = SimpleNamespace(
        status=status,
        starts_at=now - timedelta(hours=2),
        ends_at=now - timedelta(hours=1),
    )

    assert _effective_status(auction, now, bid_count=0) == status
