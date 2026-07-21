import httpx
from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from loguru import logger
from app.core.config import settings


class SupabaseAuthService:
    """
    Service wrapper for interacting with Supabase Auth API.
    """
    def __init__(self) -> None:
        self.base_url = settings.SUPABASE_URL.rstrip("/")
        self.headers = {
            "apikey": settings.SUPABASE_KEY,
            "Authorization": f"Bearer {settings.SUPABASE_KEY}",
            "Content-Type": "application/json"
        }

    async def signup(self, email: str, password: str, display_name: Optional[str] = None) -> Dict[str, Any]:
        """
        Sign up a new user via Supabase Auth.
        """
        url = f"{self.base_url}/auth/v1/signup"
        payload = {
            "email": email,
            "password": password,
            "options": {
                "data": {
                    "display_name": display_name or email.split("@")[0]
                }
            }
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(url, headers=self.headers, json=payload)
                if response.status_code != 200:
                    error_data = response.json()
                    logger.bind(category="security").error(f"Supabase Signup error: {error_data}")
                    raise HTTPException(
                        status_code=response.status_code,
                        detail=error_data.get("msg", "Error during signup process.")
                    )
                return response.json()
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Auth provider is currently unreachable."
                )

    async def login(self, email: str, password: str) -> Dict[str, Any]:
        """
        Authenticate user with email and password.
        """
        url = f"{self.base_url}/auth/v1/token?grant_type=password"
        payload = {
            "email": email,
            "password": password
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(url, headers=self.headers, json=payload)
                if response.status_code != 200:
                    error_data = response.json()
                    logger.bind(category="security").error(f"Supabase Login error: {error_data}")
                    raise HTTPException(
                        status_code=response.status_code,
                        detail=error_data.get("error_description", "Invalid login credentials.")
                    )
                return response.json()
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Auth provider is currently unreachable."
                )

    async def refresh_token(self, refresh_token: str) -> Dict[str, Any]:
        """
        Refresh active access token using refresh token.
        """
        url = f"{self.base_url}/auth/v1/token?grant_type=refresh_token"
        payload = {
            "refresh_token": refresh_token
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(url, headers=self.headers, json=payload)
                if response.status_code != 200:
                    error_data = response.json()
                    logger.bind(category="security").error(f"Supabase Refresh Token error: {error_data}")
                    raise HTTPException(
                        status_code=response.status_code,
                        detail=error_data.get("error_description", "Invalid refresh token.")
                    )
                return response.json()
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Auth provider is currently unreachable."
                )

    async def logout(self, access_token: str) -> None:
        """
        Logout user by invalidating token in Supabase.
        """
        url = f"{self.base_url}/auth/v1/logout"
        headers = self.headers.copy()
        headers["Authorization"] = f"Bearer {access_token}"

        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(url, headers=headers)
                if response.status_code not in [200, 204, 401]:  # 401 means token already invalid/expired
                    error_data = response.json()
                    logger.bind(category="security").error(f"Supabase Logout error: {error_data}")
                    raise HTTPException(
                        status_code=response.status_code,
                        detail=error_data.get("msg", "Error during logout process.")
                    )
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Auth provider is currently unreachable."
                )

    async def delete_user_admin(self, user_id: str) -> None:
        """
        Delete a user account from Supabase Auth via Service Role key (Admin privilege).
        """
        url = f"{self.base_url}/auth/v1/admin/users/{user_id}"
        headers = {
            "apikey": settings.SUPABASE_SERVICE_KEY,
            "Authorization": f"Bearer {settings.SUPABASE_SERVICE_KEY}",
            "Content-Type": "application/json"
        }

        async with httpx.AsyncClient() as client:
            try:
                response = await client.delete(url, headers=headers)
                if response.status_code not in [200, 204]:
                    error_data = response.json()
                    logger.bind(category="security").error(f"Supabase Admin Delete User error: {error_data}")
                    raise HTTPException(
                        status_code=response.status_code,
                        detail=error_data.get("msg", "Error deleting user account from auth system.")
                    )
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Auth provider is currently unreachable."
                )


# Global instance
auth_service = SupabaseAuthService()
