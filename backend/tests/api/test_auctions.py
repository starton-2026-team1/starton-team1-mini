from collections.abc import AsyncIterator, Iterator
from datetime import datetime
from unittest.mock import AsyncMock

import pytest
from httpx import ASGITransport, AsyncClient

from app.api.dependencies import get_current_user
from app.api.v1 import auctions
from app.core.database import get_db_session
from app.core.exceptions import (
    AuctionNotFoundError,
    AuctionPermissionError,
    AuctionStateError,
    BidAmountError,
)
from app.main import app
from app.models.enums import AuctionStatus
from app.models.user import User
from app.schemas.auction import AuctionDetailResponse, AuctionPreviewResponse
from app.schemas.bid import AuctionBroadcastMessage, BidResponse


@pytest.fixture
def auction_service(monkeypatch: pytest.MonkeyPatch) -> Iterator[AsyncMock]:
    mocked = AsyncMock()
    monkeypatch.setattr(auctions, "auction_service", mocked)
    yield mocked


@pytest.fixture
def auction_dependencies() -> Iterator[object]:
    session = object()
    user = User(id=7, phone_number="01012345678", name="입찰자")
    app.dependency_overrides[get_db_session] = lambda: session
    app.dependency_overrides[get_current_user] = lambda: user
    yield session
    app.dependency_overrides.clear()


@pytest.fixture
async def client() -> AsyncIterator[AsyncClient]:
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as test_client:
        yield test_client


def make_preview() -> AuctionPreviewResponse:
    return AuctionPreviewResponse(
        id=3,
        title="테스트 경매",
        category_name="디지털기기",
        status=AuctionStatus.ACTIVE,
        thumbnail_url="/static/uploads/test.jpg",
        created_at=datetime(2026, 8, 23, 9),
        start_price=10000,
        current_price=12000,
        minimum_bid_unit=1000,
        bid_count=2,
        starts_at=datetime(2026, 8, 23, 10),
        ends_at=datetime(2026, 8, 24, 10),
    )


def make_detail() -> AuctionDetailResponse:
    preview = make_preview()
    return AuctionDetailResponse(
        id=preview.id,
        title=preview.title,
        description="상품 설명",
        category_name=preview.category_name,
        seller_name="판매자",
        seller_id=9,
        winner_name=None,
        status=preview.status,
        image_urls=[preview.thumbnail_url or ""],
        start_price=preview.start_price,
        current_price=preview.current_price,
        minimum_bid_unit=preview.minimum_bid_unit,
        starts_at=preview.starts_at,
        ends_at=preview.ends_at,
        bids=[],
    )


async def test_list_auctions_passes_filter_and_pagination(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
) -> None:
    auction_service.list_auctions.return_value = ([make_preview()], 1)

    response = await client.get(
        "/api/v1/auctions?status=ACTIVE&offset=5&limit=10",
    )

    assert response.status_code == 200
    assert response.json()["items"][0]["id"] == 3
    assert response.json()["items"][0]["starts_at"].endswith("+09:00")
    auction_service.list_auctions.assert_awaited_once_with(
        auction_dependencies,
        status=AuctionStatus.ACTIVE,
        offset=5,
        limit=10,
    )


async def test_get_auction_returns_detail(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
) -> None:
    auction_service.get_detail.return_value = make_detail()

    response = await client.get("/api/v1/auctions/3")

    assert response.status_code == 200
    assert response.json()["title"] == "테스트 경매"
    auction_service.get_detail.assert_awaited_once_with(auction_dependencies, 3)


async def test_get_auction_maps_not_found_to_404(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
) -> None:
    auction_service.get_detail.side_effect = AuctionNotFoundError(
        "경매를 찾을 수 없습니다.",
    )

    response = await client.get("/api/v1/auctions/999")

    assert response.status_code == 404
    assert response.json() == {"detail": "경매를 찾을 수 없습니다."}


@pytest.mark.parametrize(
    ("error", "expected_status"),
    [
        (AuctionPermissionError("판매자는 입찰할 수 없습니다."), 403),
        (AuctionStateError("진행 중인 경매가 아닙니다."), 409),
        (BidAmountError("입찰 금액이 부족합니다."), 409),
    ],
)
async def test_create_bid_maps_domain_errors(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
    error: Exception,
    expected_status: int,
) -> None:
    auction_service.place_bid.side_effect = error

    response = await client.post(
        "/api/v1/auctions/3/bids",
        json={"amount": 13000},
    )

    assert response.status_code == expected_status
    assert response.json() == {"detail": str(error)}


async def test_create_bid_returns_broadcast_message(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
) -> None:
    auction_service.place_bid.return_value = AuctionBroadcastMessage(
        current_price=13000,
        next_bid_price=14000,
        ends_at=datetime(2026, 8, 24, 10),
        remaining_extension_count=1,
        latest_bid=BidResponse(
            bidder_name="입*자",
            amount=13000,
            created_at=datetime(2026, 8, 23, 10),
        ),
    )

    response = await client.post(
        "/api/v1/auctions/3/bids",
        json={"amount": 13000},
    )

    assert response.status_code == 201
    assert response.json()["next_bid_price"] == 14000
    assert response.json()["ends_at"].endswith("+09:00")
    assert response.json()["remaining_extension_count"] == 1
    auction_service.place_bid.assert_awaited_once_with(
        auction_dependencies,
        auction_id=3,
        bidder_id=7,
        amount=13000,
    )


async def test_cancel_auction_returns_cancelled_status(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
) -> None:
    auction_service.cancel_auction.return_value = {
        "id": 3,
        "status": AuctionStatus.CANCELLED,
    }

    response = await client.patch("/api/v1/auctions/3/cancel")

    assert response.status_code == 200
    assert response.json() == {"id": 3, "status": "CANCELLED"}
    auction_service.cancel_auction.assert_awaited_once_with(
        auction_dependencies,
        auction_id=3,
        seller_id=7,
    )


async def test_complete_trade_returns_trade_completed_status(
    client: AsyncClient,
    auction_service: AsyncMock,
    auction_dependencies: object,
) -> None:
    auction_service.complete_trade.return_value = {
        "id": 3,
        "status": AuctionStatus.TRADE_COMPLETED,
    }

    response = await client.patch("/api/v1/auctions/3/trade-complete")

    assert response.status_code == 200
    assert response.json() == {"id": 3, "status": "TRADE_COMPLETED"}
