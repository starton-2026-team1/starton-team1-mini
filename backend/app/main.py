from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.database import check_database_connection, close_database_connection


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    await check_database_connection()
    yield
    await close_database_connection()


app = FastAPI(title="Starton API", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(api_router, prefix="/api/v1")
# 경매 상품 이미지를 /static/uploads/{파일명} 으로 그대로 서빙
# (check_dir=False: 앱 기동 시점엔 uploads 폴더가 아직 없을 수 있어서 에러 안 나게)
app.mount(
    "/static/uploads",
    StaticFiles(directory=settings.upload_dir, check_dir=False),
    name="uploads",
)


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
# 실행법 : python -m app.main