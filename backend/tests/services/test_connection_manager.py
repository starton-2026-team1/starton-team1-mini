from unittest.mock import AsyncMock

from fastapi import WebSocket

from app.core.time import now_kst_naive
from app.schemas.bid import AuctionBroadcastMessage, BidResponse
from app.services.connection_manager import ConnectionManager


async def test_broadcast_removes_failed_socket_and_continues() -> None:
    manager = ConnectionManager()
    failed_socket = AsyncMock(spec=WebSocket)
    active_socket = AsyncMock(spec=WebSocket)
    failed_socket.send_text.side_effect = RuntimeError("연결 종료")
    await manager.connect(1, failed_socket)
    await manager.connect(1, active_socket)
    message = AuctionBroadcastMessage(
        current_price=12000,
        next_bid_price=13000,
        latest_bid=BidResponse(
            bidder_name="입*자",
            amount=12000,
            created_at=now_kst_naive(),
        ),
    )

    await manager.broadcast(1, message)
    await manager.broadcast(1, message)

    assert failed_socket.send_text.await_count == 1
    assert active_socket.send_text.await_count == 2
