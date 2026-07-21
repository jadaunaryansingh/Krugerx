from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database.session import get_db
from app.database.models import User, Setting
from app.schemas.response import APIResponse
from app.schemas.settings import SettingResponse, SettingUpdate
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/settings",
    tags=["Settings"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


@router.get("", response_model=APIResponse[SettingResponse])
async def get_user_settings(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[SettingResponse]:
    """
    Fetch the settings profile of the currently logged-in user.
    Creates default settings if they are not initialized yet.
    """
    stmt = select(Setting).where(Setting.user_id == current_user.id)
    res = await db.execute(stmt)
    setting = res.scalars().first()

    if not setting:
        # Generate defaults dynamically
        setting = Setting(user_id=current_user.id)
        db.add(setting)
        await db.commit()
        await db.refresh(setting)

    return APIResponse(
        success=True,
        message="Settings retrieved successfully.",
        data=SettingResponse.model_validate(setting)
    )


@router.put("", response_model=APIResponse[SettingResponse])
async def update_user_settings(
    body: SettingUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[SettingResponse]:
    """
    Update configuration options for the current user.
    """
    stmt = select(Setting).where(Setting.user_id == current_user.id)
    res = await db.execute(stmt)
    setting = res.scalars().first()

    if not setting:
        setting = Setting(user_id=current_user.id)
        db.add(setting)

    # Apply updates dynamically
    update_data = body.model_dump(exclude_unset=True)
    for key, val in update_data.items():
        setattr(setting, key, val)

    await db.commit()
    await db.refresh(setting)

    return APIResponse(
        success=True,
        message="Settings updated successfully.",
        data=SettingResponse.model_validate(setting)
    )
