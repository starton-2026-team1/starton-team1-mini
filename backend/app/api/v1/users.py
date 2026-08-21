from fastapi import APIRouter

from app.api.dependencies import CurrentUserDependency, UserServiceDependency
from app.schemas.user import UserNameUpdateRequest, UserResponse

router = APIRouter()


@router.patch('/me', response_model=UserResponse)
async def update_my_name(
    request: UserNameUpdateRequest,
    current_user: CurrentUserDependency,
    service: UserServiceDependency,
) -> UserResponse:
    user = await service.update_name(current_user, request.name)
    return UserResponse.model_validate(user)
