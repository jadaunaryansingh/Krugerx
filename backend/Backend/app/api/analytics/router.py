import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Request
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

router = APIRouter(
    prefix="/analytics",
    tags=["Analytics & Feedback"],
    dependencies=[Depends(check_rate_limit)]
)


@router.post("/feedback", response_model=APIResponse[FeedbackResponse], status_code=status.HTTP_201_CREATED)
async def submit_feedback(
    body: FeedbackCreate,
    request: Request,
    db: AsyncSession = Depends(get_db)
) -> APIResponse[FeedbackResponse]:
    """
    Submits user feedback or bug report details.
    Supports both anonymous submissions and authenticated users.
    """
    user_id = None
    # Attempt to extract user context if logged in
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        try:
            current_user = await get_current_user(dependencies=Depends(get_current_user))
            user_id = current_user.id
        except Exception:
            pass

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
    request: Request,
    db: AsyncSession = Depends(get_db)
) -> APIResponse[CrashReportResponse]:
    """
    Upload application core logs or crash stack traces for diagnostics.
    """
    user_id = None
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        try:
            # Parse token if available, but do not fail requests if auth is invalid
            from app.core.jwt import verify_supabase_token
            token = auth_header.split(" ")[1]
            payload = verify_supabase_token(token)
            user_id = uuid.UUID(payload.get("sub"))
        except Exception:
            pass

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


@router.get("/feedback", response_model=APIResponse[List[FeedbackResponse]], dependencies=[Depends(get_current_user)])
async def list_feedback(
    category: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[FeedbackResponse]]:
    """
    List historical feedback items. (Admin/User access)
    """
    stmt = select(Feedback).order_by(Feedback.created_at.desc())
    if category:
        stmt = stmt.where(Feedback.category == category)
    
    res = await db.execute(stmt)
    items = res.scalars().all()

    return APIResponse(
        success=True,
        message="Feedback logs loaded.",
        data=[FeedbackResponse.model_validate(i) for i in items]
    )


@router.get("/crash", response_model=APIResponse[List[CrashReportResponse]], dependencies=[Depends(get_current_user)])
async def list_crashes(
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[CrashReportResponse]]:
    """
    List historical app crash traces. (Diagnostic team access)
    """
    stmt = select(CrashReport).order_by(CrashReport.created_at.desc())
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


@router.get("/summary", response_model=APIResponse[AnalyticsSummaryResponse], dependencies=[Depends(get_current_user)])
async def get_analytics_summary(
    db: AsyncSession = Depends(get_db)
) -> APIResponse[AnalyticsSummaryResponse]:
    """
    Return high-level system usage dashboards.
    """
    # Active Users
    users_stmt = select(func.count(User.id)).where(User.is_active == True)
    users_res = await db.execute(users_stmt)
    users_count = users_res.scalar() or 0

    # Sync operations
    sync_stmt = select(func.count(SyncQueue.id))
    sync_res = await db.execute(sync_stmt)
    sync_count = sync_res.scalar() or 0

    # Crash counts
    crash_stmt = select(func.count(CrashReport.id))
    crash_res = await db.execute(crash_stmt)
    crash_count = crash_res.scalar() or 0

    # Avg feedback rating
    rating_stmt = select(func.avg(Feedback.rating))
    rating_res = await db.execute(rating_stmt)
    avg_rating = rating_res.scalar()
    avg_rating_val = float(avg_rating) if avg_rating is not None else 5.0

    data = AnalyticsSummaryResponse(
        total_active_users=users_count,
        total_sync_events=sync_count,
        crash_reports_count=crash_count,
        feedback_average_rating=avg_rating_val
    )
    return APIResponse(
        success=True,
        message="Analytics metrics dashboard summary calculated.",
        data=data
    )
