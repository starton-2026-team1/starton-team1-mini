from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.database import check_database_connection, close_database_connection


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    await check_database_connection()
    yield
    await close_database_connection()


app = FastAPI(title="Starton API", version="1.0.0", lifespan=lifespan)
app.include_router(api_router, prefix="/api/v1")


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
