from fastapi import APIRouter

router = APIRouter()


@router.get("")
async def list_users() -> list[dict[str, object]]:
    return []
