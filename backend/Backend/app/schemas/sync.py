import uuid
import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field


class DeviceRegisterRequest(BaseModel):
    device_name: str = Field(..., max_length=100)
    device_type: str = Field(..., description="desktop, mobile, tablet")
    os: str = Field(..., max_length=50)
    client_version: str = Field(..., max_length=50)
    push_token: Optional[str] = None


class DeviceResponse(BaseModel):
    id: uuid.UUID
    device_name: str
    device_type: str
    os: str
    client_version: str
    push_token: Optional[str] = None
    last_active_at: datetime.datetime

    class Config:
        from_attributes = True


class SyncItemRequest(BaseModel):
    entity_type: str = Field(..., description="bookmark, history, setting, tab, collection")
    entity_id: uuid.UUID
    action: str = Field(..., description="create, update, delete")
    payload: Optional[Dict[str, Any]] = None


class SyncItemResponse(BaseModel):
    id: uuid.UUID
    entity_type: str
    entity_id: uuid.UUID
    action: str
    payload: Optional[Dict[str, Any]] = None
    synced_at: Optional[datetime.datetime] = None

    class Config:
        from_attributes = True


class SyncPullResponse(BaseModel):
    queue_items: List[SyncItemResponse]
    server_time: datetime.datetime
