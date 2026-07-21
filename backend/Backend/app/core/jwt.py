import httpx
from typing import Dict, Any
import jwt
from fastapi import HTTPException, status
from loguru import logger
from app.core.config import settings


def verify_supabase_token(token: str) -> Dict[str, Any]:
    """
    Verifies the Supabase-issued JWT token against the project's secret locally,
    with a fallback to validating directly against Supabase Auth API.
    Returns the decoded token payload if valid, otherwise raises HTTP 401.
    """
    try:
        # Supabase uses standard HS256 JWTs signed with the project JWT secret
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated"
        )
        return payload
    except Exception as local_err:
        logger.bind(category="security").info(f"Local JWT decoding failed ({local_err}). Falling back to Supabase API validation...")
        
        # Fallback: Ask Supabase Auth directly to verify the token
        try:
            url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/user"
            headers = {
                "apikey": settings.SUPABASE_KEY,
                "Authorization": f"Bearer {token}"
            }
            with httpx.Client(timeout=5.0) as client:
                response = client.get(url, headers=headers)
                if response.status_code == 200:
                    user_data = response.json()
                    # Map Supabase response to match expected payload format (sub, email, etc.)
                    return {
                        "sub": user_data.get("id"),
                        "email": user_data.get("email"),
                        "role": user_data.get("role", "authenticated")
                    }
                else:
                    logger.bind(category="security").warning(f"Supabase API token verification failed: {response.text}")
        except Exception as api_err:
            logger.bind(category="errors").error(f"Failed to reach Supabase API for token validation: {str(api_err)}")

        # Raise 401 if both options failed
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

