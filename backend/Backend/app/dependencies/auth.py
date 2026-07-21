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
    payload = verify_supabase_token(token)

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

    # Search user in local cache db
    stmt = select(User).where(User.id == user_uuid)
    result = await db.execute(stmt)
    user = result.scalars().first()

    if not user:
        # Synchronize user locally in a single transaction block
        email = payload.get("email", f"{user_uuid.hex[:8]}@krugerx-browser.local")
        
        try:
            # Create user
            user = User(id=user_uuid, email=email, is_active=True)
            db.add(user)
            await db.flush()

            # Create default Profile
            profile = Profile(
                user_id=user_uuid, 
                display_name=email.split("@")[0] if email else "Krugerx User",
                avatar_url=None
            )
            db.add(profile)

            # Create default Settings
            settings_entry = Setting(
                user_id=user_uuid,
                theme="system",
                search_engine="google",
                homepage_url="https://google.com",
                language="en",
                font_size=14,
                privacy_tracking_protection=True,
                ai_provider="openai",
                ai_model="gpt-4o"
            )
            db.add(settings_entry)
            
            await db.commit()
            logger.bind(category="security").info(
                f"Successfully synced User (JIT): {user_uuid} | Email: {email}"
            )
        except Exception as e:
            await db.rollback()
            logger.bind(category="errors").error(
                f"Failed to synchronize user JIT locally: {str(e)}"
            )
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
