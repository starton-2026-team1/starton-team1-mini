from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.services.connection_manager import connection_manager

router = APIRouter()


# 경매별 실시간 입찰 알림용 웹소켓 엔드포인트 (입찰 저장/검증은 REST 쪽에서 처리)
@router.websocket("/{auction_id}/ws")
async def auction_ws(websocket: WebSocket, auction_id: int) -> None:
    # 연결되면 해당 경매의 브로드캐스트 대상 목록에 등록
    await connection_manager.connect(auction_id, websocket)
    try:
        # 클라이언트가 보내는 메시지는 안 쓰지만, 연결을 유지하려면 계속 받아야 함
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        # 연결이 끊기면 브로드캐스트 대상에서 제거
        connection_manager.disconnect(auction_id, websocket)
