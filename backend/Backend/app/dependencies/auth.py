import uuid
from typing import Dict, Any
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from loguru import logger

from app.core.jwt import verify_supabase_token
from app.database.session import get_db
from app.database.models import User, Profile, Setting

# Define HTTPBearer scheme for Swagger/FastAPI docs authentication
security = HTTPBearer(auto_error=True)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    """
    Decodes the Bearer token, verifies it against Supabase JWT, 
    and returns the local database User model.
    Performs JIT (Just-In-Time) sync if the user exists in Supabase Auth 
    but has not been cached in the local database.
    """
    token = credentials.credentials
    payload = await verify_supabase_token(token)

    user_id_str = payload.get("sub")
    if not user_id_str:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token payload is missing user identification identifier (sub)."
        )

    try:
        user_uuid = uuid.UUID(user_id_str)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user identifier format in token."
        )

    # Search user in local cache db by email or id
    email = payload.get("email", f"{user_uuid.hex[:8]}@krugerx-browser.local")
    stmt = select(User).where((User.id == user_uuid) | (User.email == email))
    result = await db.execute(stmt)
    user = result.scalars().first()

    if user and user.id != user_uuid:
        # UUID mismatch (e.g. password user logging in via Google). Reconcile by migrating dependents.
        try:
            old_id = user.id
            from sqlalchemy import update
            
            stmt = update(User).where(User.id == old_id).values(id=user_uuid)
            await db.execute(stmt)
            await db.commit()

            user = (await db.execute(select(User).where(User.id == user_uuid))).scalars().first()

            logger.bind(category="security").info(f"Reconciled User UUID from {old_id} to {user_uuid} for {email}")
        except Exception as e:
            await db.rollback()
            logger.bind(category="errors").error(f"Failed to reconcile user UUID locally: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error synchronizing user session details."
            )
            
    if not user:
        # Synchronize user locally (New User)
        try:
            new_user = User(id=user_uuid, email=email, is_active=True)
            db.add(new_user)
            await db.flush()

            profile = Profile(
                user_id=user_uuid, 
                display_name=email.split("@")[0] if email else "Krugerx User",
            )
            db.add(profile)

            setting = Setting(user_id=user_uuid)
            db.add(setting)

            await db.commit()
            logger.bind(category="security").info(f"Successfully synced User (JIT): {user_uuid} | Email: {email}")
            user = new_user
        except Exception as e:
            await db.rollback()
            logger.bind(category="errors").error(f"Failed to synchronize user JIT locally: {str(e)}")
            # Try to fetch one last time in case of a lost race condition
            user = (await db.execute(select(User).where(User.email == email))).scalars().first()
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Error synchronizing user session details."
                )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is deactivated."
        )

    return user
