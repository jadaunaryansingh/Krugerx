import uuid
from typing import Optional, List
from pydantic import BaseModel, Field


class BrowserSessionCreate(BaseModel):
    device_id: uuid.UUID
    profile_name: str = Field("Default", max_length=100)


class BrowserSessionResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    device_id: Optional[uuid.UUID] = None
    profile_name: str
    is_active: bool

    class Config:
        from_attributes = True


class ExtensionRegisterRequest(BaseModel):
    extension_id: str = Field(..., max_length=100, description="Unique extension store ID")
    name: str = Field(..., max_length=255)
    version: str = Field(..., max_length=50)
    enabled: bool = True


class ExtensionResponse(BaseModel):
    extension_id: str
    name: str
    version: str
    enabled: bool
