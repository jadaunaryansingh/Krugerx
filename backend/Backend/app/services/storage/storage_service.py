import httpx
from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from loguru import logger

from app.core.config import settings


class SupabaseStorageService:
    """
    Wrapper for interacting directly with Supabase Storage REST API.
    """
    def __init__(self) -> None:
        self.base_url = settings.SUPABASE_URL.rstrip("/")
        self.bucket = settings.SUPABASE_STORAGE_BUCKET
        self.headers = {
            "apikey": settings.SUPABASE_KEY,
            "Authorization": f"Bearer {settings.SUPABASE_KEY}"
        }

    async def upload_file(self, file_path: str, file_bytes: bytes, content_type: str) -> Dict[str, Any]:
        """
        Uploads raw file bytes to the configured bucket path in Supabase Storage.
        """
        url = f"{self.base_url}/storage/v1/object/{self.bucket}/{file_path.lstrip('/')}"
        
        headers = self.headers.copy()
        headers["Content-Type"] = content_type

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, headers=headers, content=file_bytes, timeout=30.0)
                if res.status_code != 200:
                    # In case of duplicate/exist issues, try PUT to overwrite or raise
                    error_data = res.json()
                    logger.bind(category="errors").error(f"Supabase Storage Upload failed: {error_data}")
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=error_data.get("message", "Error uploading file to storage.")
                    )
                return res.json()
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP connection to Supabase storage failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Cloud storage provider is currently unreachable."
                )

    async def delete_file(self, file_path: str) -> Dict[str, Any]:
        """
        Delete a file from the bucket.
        """
        url = f"{self.base_url}/storage/v1/object/{self.bucket}/{file_path.lstrip('/')}"
        
        async with httpx.AsyncClient() as client:
            try:
                res = await client.delete(url, headers=self.headers)
                if res.status_code != 200:
                    error_data = res.json()
                    logger.bind(category="errors").error(f"Supabase Storage Delete failed: {error_data}")
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=error_data.get("message", "Error deleting file from storage.")
                    )
                return res.json()
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Cloud storage provider is currently unreachable."
                )

    async def create_signed_url(self, file_path: str, expires_in: int = 3600) -> str:
        """
        Create a pre-signed retrieval link valid for `expires_in` seconds.
        """
        url = f"{self.base_url}/storage/v1/object/sign/{self.bucket}/{file_path.lstrip('/')}"
        payload = {"expiresIn": expires_in}

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, headers=self.headers, json=payload)
                if res.status_code != 200:
                    error_data = res.json()
                    logger.bind(category="errors").error(f"Supabase Signed URL creation failed: {error_data}")
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=error_data.get("message", "Error generating pre-signed URL.")
                    )
                data = res.json()
                signed_path = data.get("signedURL", "")
                
                # Combine base path if the url returned is relative
                if signed_path.startswith("/"):
                    return f"{self.base_url}{signed_path}"
                return signed_path
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Cloud storage provider is currently unreachable."
                )

    async def rename_file(self, old_path: str, new_path: str) -> Dict[str, Any]:
        """
        Rename/Move an object path in the bucket.
        """
        url = f"{self.base_url}/storage/v1/object/move"
        payload = {
            "bucketId": self.bucket,
            "srcKey": old_path.lstrip("/"),
            "destKey": new_path.lstrip("/")
        }

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, headers=self.headers, json=payload)
                if res.status_code != 200:
                    error_data = res.json()
                    logger.bind(category="errors").error(f"Supabase Storage Move failed: {error_data}")
                    raise HTTPException(
                        status_code=res.status_code,
                        detail=error_data.get("message", "Error renaming file in storage.")
                    )
                return res.json()
            except httpx.RequestError as e:
                logger.bind(category="errors").error(f"HTTP request to Supabase failed: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Cloud storage provider is currently unreachable."
                )


storage_service = SupabaseStorageService()
