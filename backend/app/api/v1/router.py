from fastapi import APIRouter

from app.api.v1.products import router as products_router
from app.api.v1.users import router as users_router

api_router = APIRouter()

api_router.include_router(users_router, prefix="/users", tags=["Users"])
api_router.include_router(products_router, prefix="/products", tags=["Products"])