import uuid
import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field


class FeedbackCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5, description="Satisfaction score between 1 and 5")
    comment: Optional[str] = Field(None, description="Detailed user commentary")
    category: str = Field("general", description="crash, feature, general, ui")


class FeedbackResponse(BaseModel):
    id: uuid.UUID
    user_id: Optional[uuid.UUID] = None
    rating: int
    comment: Optional[str] = None
    category: str
    created_at: datetime.datetime

    class Config:
        from_attributes = True


class CrashReportCreate(BaseModel):
    device_id: Optional[uuid.UUID] = None
    stack_trace: str
    app_version: str
    os_version: str
    metadata: Optional[Dict[str, Any]] = None


class CrashReportResponse(BaseModel):
    id: uuid.UUID
    user_id: Optional[uuid.UUID] = None
    device_id: Optional[uuid.UUID] = None
    stack_trace: str
    app_version: str
    os_version: str
    metadata_json: Optional[Dict[str, Any]] = None
    created_at: datetime.datetime

    class Config:
        from_attributes = True


class ActivityLogResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    action: str
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    created_at: datetime.datetime

    class Config:
        from_attributes = True


class AnalyticsSummaryResponse(BaseModel):
    total_active_users: int
    total_sync_events: int
    crash_reports_count: int
    feedback_average_rating: float
