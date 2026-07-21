import uuid
import datetime
from typing import Optional
from pydantic import BaseModel, Field


class DownloadCreate(BaseModel):
    filename: str = Field(..., max_length=255)
    url: str
    total_bytes: Optional[int] = None


class DownloadUpdate(BaseModel):
    status: Optional[str] = Field(None, description="queued, downloading, completed, failed, cancelled")
    progress: Optional[float] = Field(None, ge=0.0, le=1.0)
    downloaded_bytes: Optional[int] = None
    total_bytes: Optional[int] = None
    completed_time: Optional[datetime.datetime] = None


class DownloadResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    filename: str
    url: str
    status: str
    progress: float
    total_bytes: Optional[int] = None
    downloaded_bytes: Optional[int] = None
    completed_time: Optional[datetime.datetime] = None

    class Config:
        from_attributes = True
