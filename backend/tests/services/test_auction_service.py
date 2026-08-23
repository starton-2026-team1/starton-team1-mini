from datetime import datetime, timedelta
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest

from app.core.exceptions import AuctionPermissionError
from app.models.enums import AuctionStatus
from app.repositories.auction_repository import AuctionRepository
from app.repositories.bid_repository import BidRepository
from app.services.auction_service import AuctionService
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
