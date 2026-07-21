from typing import Optional
from pydantic import BaseModel, Field


class FileUploadResponse(BaseModel):
    file_path: str
    filename: str
    content_type: str
    url: Optional[str] = None


class SignedUrlRequest(BaseModel):
    file_path: str
    expires_in: int = Field(3600, ge=60, le=604800, description="Expiration time in seconds (1 min to 7 days)")


class SignedUrlResponse(BaseModel):
    file_path: str
    signed_url: str
    expires_in: int


class FileRenameRequest(BaseModel):
    old_path: str
    new_path: str
