from collections import defaultdict

from fastapi import WebSocket
from pydantic import BaseModel


# 경매별로 연결된 웹소켓들을 들고 있다가, 입찰이 생기면 그 경매를 보는 사람들에게만 알림
class ConnectionManager:
    def __init__(self) -> None:
        self._connections: dict[int, set[WebSocket]] = defaultdict(set)

    async def connect(self, auction_id: int, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections[auction_id].add(websocket)

    def disconnect(self, auction_id: int, websocket: WebSocket) -> None:
        connections = self._connections.get(auction_id)
        if connections is None:
            return

        connections.discard(websocket)
        # 남은 연결이 없으면 딕셔너리에서도 정리
        if not connections:
            del self._connections[auction_id]

    async def broadcast(self, auction_id: int, message: BaseModel) -> None:
        connections = self._connections.get(auction_id)
        if not connections:
            return

        payload = message.model_dump_json()
        # 순회 중 끊기는 연결이 있을 수 있어 리스트로 복사해서 순회
        for websocket in list(connections):
            await websocket.send_text(payload)


# REST 핸들러와 웹소켓 핸들러가 같은 인스턴스를 봐야 하므로 프로세스 전체에서 하나만 공유
connection_manager = ConnectionManager()
