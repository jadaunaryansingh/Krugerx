import httpx
from typing import Dict, Any
import jwt
from fastapi import HTTPException, status
from loguru import logger
from app.core.config import settings

# ACTION REQUIRED — SUPABASE_JWT_SECRET misconfiguration:
# The value in .env is currently set to the service_role JWT (a long eyJ... token).
# It must be the RAW HS256 signing secret string from:
#   Supabase Dashboard → Project Settings → API → JWT Secret
# (it looks like a short random string, NOT a JWT).
# Until fixed, local decode will always fail and every request makes a Supabase API
# round-trip — auth breaks completely during Supabase outages.
_JWT_SECRET_IS_MISCONFIGURED = (
    settings.SUPABASE_JWT_SECRET.startswith("eyJ")
    and len(settings.SUPABASE_JWT_SECRET) > 100
)
if _JWT_SECRET_IS_MISCONFIGURED:
    logger.bind(category="security").warning(
        "SUPABASE_JWT_SECRET appears to be a JWT token, not a raw signing secret. "
        "Local token verification is disabled. Set the correct raw secret from "
        "Supabase Dashboard → Project Settings → API → JWT Secret."
    )


async def verify_supabase_token(token: str) -> Dict[str, Any]:
    """
    Verifies the Supabase-issued JWT token against the project's secret locally,
    with a fallback to validating directly against Supabase Auth API.
    Returns the decoded token payload if valid, otherwise raises HTTP 401.

    NOTE: SUPABASE_JWT_SECRET must be the raw HS256 signing key from Supabase
    Dashboard (a short plain string), NOT the service role JWT.
    """
    if not _JWT_SECRET_IS_MISCONFIGURED:
        try:
            payload = jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                audience="authenticated",
                issuer=settings.SUPABASE_URL
            )
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication token has expired.",
                headers={"WWW-Authenticate": "Bearer"},
            )
        except jwt.InvalidTokenError as local_err:
            logger.bind(category="security").info(
                f"Local JWT decode failed ({local_err}). Falling back to Supabase API."
            )

    # Fallback: validate directly against Supabase Auth API.
    # Used when: (a) JWT secret is misconfigured, (b) local decode fails for other reasons.
    try:
        url = f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/user"
        headers = {
            "apikey": settings.SUPABASE_KEY,
            "Authorization": f"Bearer {token}"
        }
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(url, headers=headers)
            if response.status_code == 200:
                user_data = response.json()
                return {
                    "sub": user_data.get("id"),
                    "email": user_data.get("email"),
                    "role": user_data.get("role", "authenticated")
                }
            else:
                logger.bind(category="security").warning(
                    f"Supabase API token verification failed: {response.status_code}"
                )
    except httpx.TimeoutException:
        logger.bind(category="errors").error("Supabase API token validation timed out.")
    except Exception as api_err:
        logger.bind(category="errors").error(
            f"Failed to reach Supabase API for token validation: {str(api_err)}"
        )

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired authentication token.",
        headers={"WWW-Authenticate": "Bearer"},
    )

