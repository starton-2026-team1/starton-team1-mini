from fastapi import FastAPI

from app.api.v1.router import api_router

app = FastAPI(title="Starton API", version="1.0.0")
app.include_router(api_router, prefix="/api/v1")


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
