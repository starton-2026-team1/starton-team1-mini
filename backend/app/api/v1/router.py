from fastapi import APIRouter

from app.api.v1.auctions import router as auctions_router
from app.api.v1.auctions_ws import router as auctions_ws_router
from app.api.v1.auth import router as auth_router
from app.api.v1.products import router as products_router
from app.api.v1.users import router as users_router

api_router = APIRouter()

api_router.include_router(users_router, prefix="/users", tags=["Users"])
api_router.include_router(
    auth_router,
    prefix="/auth",
    tags=["Authentication"],
)
api_router.include_router(products_router, prefix="/products", tags=["Products"])
# REST(목록/상세/입찰)와 웹소켓(실시간 알림)을 같은 /auctions prefix에 같이 등록
api_router.include_router(auctions_router, prefix="/auctions", tags=["Auctions"])
api_router.include_router(auctions_ws_router, prefix="/auctions", tags=["Auctions WS"])
