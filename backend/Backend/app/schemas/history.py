import uuid
import datetime
from typing import Optional
from pydantic import BaseModel, Field


class HistoryCreate(BaseModel):
    url: str
    title: Optional[str] = Field(None, max_length=500)
    device_id: Optional[uuid.UUID] = None
    visit_time: Optional[datetime.datetime] = None


class HistoryResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    device_id: Optional[uuid.UUID] = None
    url: str
    title: Optional[str] = None
    visit_time: datetime.datetime
    visit_count: int

    class Config:
        from_attributes = True
