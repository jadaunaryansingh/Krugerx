import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func

from app.database.session import get_db
from app.database.models import User, Feedback, CrashReport, ActivityLog, SyncQueue
from app.schemas.response import APIResponse
from app.schemas.analytics import (
    FeedbackCreate,
    FeedbackResponse,
    CrashReportCreate,
    CrashReportResponse,
    ActivityLogResponse,
    AnalyticsSummaryResponse
)
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit
from app.core.jwt import verify_supabase_token

# Optional bearer — does NOT raise 403 when Authorization header is absent
_optional_bearer = HTTPBearer(auto_error=False)

router = APIRouter(
    prefix="/analytics",
    tags=["Analytics & Feedback"],
    dependencies=[Depends(check_rate_limit)]
)


@router.post("/feedback", response_model=APIResponse[FeedbackResponse], status_code=status.HTTP_201_CREATED)
async def submit_feedback(
    body: FeedbackCreate,
    db: AsyncSession = Depends(get_db),
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_optional_bearer)
) -> APIResponse[FeedbackResponse]:
    """
    Submits user feedback. Supports anonymous and authenticated users.
    """
    user_id: Optional[uuid.UUID] = None
    if credentials:
        try:
            payload = verify_supabase_token(credentials.credentials)
            user_id = uuid.UUID(payload["sub"])
        except Exception:
            pass  # anonymous fallback

    feedback = Feedback(
        user_id=user_id,
        rating=body.rating,
        comment=body.comment,
        category=body.category
    )
    db.add(feedback)
    await db.commit()
    await db.refresh(feedback)

    return APIResponse(
        success=True,
        message="Thank you for your feedback!",
        data=FeedbackResponse.model_validate(feedback)
    )


@router.post("/crash", response_model=APIResponse[CrashReportResponse], status_code=status.HTTP_201_CREATED)
async def submit_crash_report(
    body: CrashReportCreate,
    db: AsyncSession = Depends(get_db),
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_optional_bearer)
) -> APIResponse[CrashReportResponse]:
    """
    Upload application crash stack traces for diagnostics.
    """
    user_id: Optional[uuid.UUID] = None
    if credentials:
        try:
            payload = verify_supabase_token(credentials.credentials)
            user_id = uuid.UUID(payload["sub"])
        except Exception:
            pass  # anonymous fallback

    report = CrashReport(
        user_id=user_id,
        device_id=body.device_id,
        stack_trace=body.stack_trace,
        app_version=body.app_version,
        os_version=body.os_version,
        metadata_json=body.metadata
    )
    db.add(report)
    await db.commit()
    await db.refresh(report)

    return APIResponse(
        success=True,
        message="Crash diagnostic report registered.",
        data=CrashReportResponse.model_validate(report)
    )


@router.get("/feedback", response_model=APIResponse[List[FeedbackResponse]])
async def list_feedback(
    category: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[FeedbackResponse]]:
    """
    List feedback submitted by the current user.
    """
    stmt = select(Feedback).where(Feedback.user_id == current_user.id).order_by(Feedback.created_at.desc())
    if category:
        stmt = stmt.where(Feedback.category == category)
    
    res = await db.execute(stmt)
    items = res.scalars().all()

    return APIResponse(
        success=True,
        message="Feedback logs loaded.",
        data=[FeedbackResponse.model_validate(i) for i in items]
    )


@router.get("/crash", response_model=APIResponse[List[CrashReportResponse]])
async def list_crashes(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[CrashReportResponse]]:
    """
    List crash reports submitted by the current user.
    """
    stmt = select(CrashReport).where(CrashReport.user_id == current_user.id).order_by(CrashReport.created_at.desc())
    res = await db.execute(stmt)
    reports = res.scalars().all()

    return APIResponse(
        success=True,
        message="Diagnostic crash reports retrieved.",
        data=[CrashReportResponse.model_validate(r) for r in reports]
    )


@router.post("/activity", response_model=APIResponse[ActivityLogResponse], dependencies=[Depends(get_current_user)])
async def log_activity(
    action: str,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[ActivityLogResponse]:
    """
    Add trace events or log specific browser activities for synchronization.
    """
    log = ActivityLog(
        user_id=current_user.id,
        action=action,
        ip_address=request.client.host if request.client else "unknown",
        user_agent=request.headers.get("user-agent", "unknown")
    )
    db.add(log)
    await db.commit()
    await db.refresh(log)

    return APIResponse(
        success=True,
        message="Activity audit log saved.",
        data=ActivityLogResponse.model_validate(log)
    )


@router.get("/summary", response_model=APIResponse[AnalyticsSummaryResponse])
async def get_analytics_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[AnalyticsSummaryResponse]:
    """
    Return usage stats scoped to the current user.
    """
    # User's own sync operations
    sync_stmt = select(func.count(SyncQueue.id)).where(SyncQueue.user_id == current_user.id)
    sync_res = await db.execute(sync_stmt)
    sync_count = sync_res.scalar() or 0

    # User's own crash reports
    crash_stmt = select(func.count(CrashReport.id)).where(CrashReport.user_id == current_user.id)
    crash_res = await db.execute(crash_stmt)
    crash_count = crash_res.scalar() or 0

    # User's own avg feedback rating
    rating_stmt = select(func.avg(Feedback.rating)).where(Feedback.user_id == current_user.id)
    rating_res = await db.execute(rating_stmt)
    avg_rating = rating_res.scalar()
    avg_rating_val = float(avg_rating) if avg_rating is not None else 5.0

    data = AnalyticsSummaryResponse(
        total_active_users=1,  # always 1 — the current user
        total_sync_events=sync_count,
        crash_reports_count=crash_count,
        feedback_average_rating=avg_rating_val
    )
    return APIResponse(
        success=True,
        message="User analytics summary calculated.",
        data=data
    )
