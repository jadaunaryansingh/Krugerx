import uuid
import datetime
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials
from loguru import logger
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.database.session import get_db
from app.database.models import User, Profile, Setting
from app.schemas.response import APIResponse
from app.schemas.auth import (
    UserSignupRequest,
    UserLoginRequest,
    TokenRefreshRequest,
    TokenResponse,
    UserMeResponse,
    UserResetPasswordRequest
)
from app.services.auth.auth_service import auth_service
from app.dependencies.auth import get_current_user, security
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(prefix="/auth", tags=["Authentication"], dependencies=[Depends(check_rate_limit)])


@router.post("/signup", response_model=APIResponse[Any], status_code=status.HTTP_201_CREATED)
async def signup(body: UserSignupRequest, db: AsyncSession = Depends(get_db)) -> APIResponse[Any]:
    """
    Register a new user account.
    Flashes credentials to Supabase Auth and registers profile locally.
    """
    res = await auth_service.signup(body.email, body.password, body.display_name)
    user_id = res.get("id")

    if user_id:
        user_uuid = uuid.UUID(user_id)
        # Check if local user already exists (rare case)
        stmt = select(User).where(User.id == user_uuid)
        existing = await db.execute(stmt)
        if not existing.scalars().first():
            try:
                user = User(id=user_uuid, email=body.email, is_active=True)
                db.add(user)
                await db.flush()

                profile = Profile(
                    user_id=user_uuid,
                    display_name=body.display_name or body.email.split("@")[0]
                )
                db.add(profile)

                setting = Setting(user_id=user_uuid)
                db.add(setting)

                await db.commit()
            except Exception as e:
                await db.rollback()
                # Do not fail request — user was created in Supabase.
                # JIT sync will pick it up on first auth request.
                logger.bind(category="errors").error(
                    f"Local DB sync failed for new user {user_uuid}: {e}"
                )

    return APIResponse(
        success=True,
        message="Signup successful. Please verify email if confirmation is enabled.",
        data=res
    )


@router.post("/login", response_model=APIResponse[TokenResponse])
async def login(body: UserLoginRequest, db: AsyncSession = Depends(get_db)) -> APIResponse[TokenResponse]:
    """
    Log in with email and password to retrieve Supabase JWT access and refresh tokens.
    """
    res = await auth_service.login(body.email, body.password)
    
    access_token = res.get("access_token")
    refresh_token = res.get("refresh_token")
    expires_in = res.get("expires_in")
    user_data = res.get("user", {})
    user_id_str = user_data.get("id")

    if not user_id_str or not access_token:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Unexpected response content received from auth provider."
        )

    user_uuid = uuid.UUID(user_id_str)

    # Sync locally if doesn't exist
    stmt = select(User).where(User.id == user_uuid)
    existing = await db.execute(stmt)
    if not existing.scalars().first():
        try:
            user = User(id=user_uuid, email=body.email, is_active=True)
            db.add(user)
            await db.flush()

            profile = Profile(
                user_id=user_uuid,
                display_name=user_data.get("user_metadata", {}).get("display_name") or body.email.split("@")[0]
            )
            db.add(profile)

            setting = Setting(user_id=user_uuid)
            db.add(setting)

            await db.commit()
        except Exception as e:
            await db.rollback()
            logger.bind(category="errors").error(
                f"Local DB sync failed on login for user {user_uuid}: {e}"
            )

    data = TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=expires_in,
        user_id=user_uuid
    )
    return APIResponse(
        success=True,
        message="Authentication successful.",
        data=data
    )



@router.post("/reset-password", response_model=APIResponse[None])
async def reset_password(body: UserResetPasswordRequest) -> APIResponse[None]:
    """
    Send a password reset email using Supabase.
    """
    await auth_service.reset_password(body.email)
    
    return APIResponse(
        success=True,
        message="Password recovery email sent.",
        data=None
    )



@router.post("/logout", response_model=APIResponse[None])
async def logout(credentials: HTTPAuthorizationCredentials = Depends(security)) -> APIResponse[None]:
    """
    Invalidates the user session on Supabase Auth.
    """
    token = credentials.credentials
    await auth_service.logout(token)
    return APIResponse(
        success=True,
        message="Logout successful."
    )


@router.get("/me", response_model=APIResponse[UserMeResponse])
async def get_me(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[UserMeResponse]:
    """
    Retrieves the currently logged-in user profile details.
    """
    stmt = (
        select(User)
        .options(selectinload(User.profile))
        .where(User.id == current_user.id)
    )
    res = await db.execute(stmt)
    user = res.scalars().first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User details not found."
        )

    # Convert User object to fit schema
    return APIResponse(
        success=True,
        message="User profile retrieved.",
        data=UserMeResponse.model_validate(user)
    )


@router.delete("/account", response_model=APIResponse[None])
async def delete_account(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Permanently deletes a user from Supabase and soft deletes locally.
    """
    # 1. Admin Delete in Supabase Auth
    await auth_service.delete_user_admin(str(current_user.id))

    # 2. Local Soft Delete
    current_user.deleted_at = datetime.datetime.now(datetime.timezone.utc)
    current_user.is_active = False
    await db.commit()

    return APIResponse(
        success=True,
        message="Account successfully scheduled for deletion."
    )
