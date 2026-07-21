import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database.session import get_db
from app.database.models import User, History
from app.schemas.response import APIResponse
from app.schemas.history import HistoryCreate, HistoryResponse
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/history",
    tags=["History"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


@router.post("", response_model=APIResponse[HistoryResponse], status_code=status.HTTP_201_CREATED)
async def record_visit(
    body: HistoryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[HistoryResponse]:
    """
    Record a website visit. If visited recently (within the last 2 hours),
    increments the visit count instead of generating a new entry.
    """
    # Check if there is an existing record for the same URL, user, and device within the last 2 hours
    two_hours_ago = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=2)
    
    stmt = (
        select(History)
        .where(
            History.user_id == current_user.id,
            History.url == body.url,
            History.visit_time >= two_hours_ago
        )
        .order_by(History.visit_time.desc())
        .limit(1)
    )
    res = await db.execute(stmt)
    existing_entry = res.scalars().first()

    if existing_entry:
        existing_entry.visit_count += 1
        existing_entry.visit_time = body.visit_time or datetime.datetime.now(datetime.timezone.utc)
        if body.title:
            existing_entry.title = body.title
        await db.commit()
        await db.refresh(existing_entry)
        return APIResponse(
            success=True,
            message="Visit count updated.",
            data=HistoryResponse.model_validate(existing_entry)
        )

    # Else create new entry
    new_entry = History(
        user_id=current_user.id,
        device_id=body.device_id,
        url=body.url,
        title=body.title,
        visit_time=body.visit_time or datetime.datetime.now(datetime.timezone.utc),
        visit_count=1
    )
    db.add(new_entry)
    await db.commit()
    await db.refresh(new_entry)

    return APIResponse(
        success=True,
        message="Visit recorded.",
        data=HistoryResponse.model_validate(new_entry)
    )


@router.get("", response_model=APIResponse[List[HistoryResponse]])
async def get_history_list(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[HistoryResponse]]:
    """
    List user browsing history entries ordered by visit time descending.
    """
    stmt = (
        select(History)
        .where(History.user_id == current_user.id)
        .order_by(History.visit_time.desc())
        .limit(limit)
        .offset(offset)
    )
    res = await db.execute(stmt)
    entries = res.scalars().all()

    return APIResponse(
        success=True,
        message="History entries retrieved.",
        data=[HistoryResponse.model_validate(e) for e in entries]
    )


@router.get("/search", response_model=APIResponse[List[HistoryResponse]])
async def search_history(
    query: str,
    limit: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[HistoryResponse]]:
    """
    Search browsing history by title or URL matching substring.
    """
    stmt = (
        select(History)
        .where(
            History.user_id == current_user.id,
            (History.title.ilike(f"%{query}%")) | (History.url.ilike(f"%{query}%"))
        )
        .order_by(History.visit_time.desc())
        .limit(limit)
    )
    res = await db.execute(stmt)
    entries = res.scalars().all()

    return APIResponse(
        success=True,
        message=f"Found {len(entries)} matching history logs.",
        data=[HistoryResponse.model_validate(e) for e in entries]
    )


@router.delete("/bulk", response_model=APIResponse[None])
async def delete_history_bulk(
    domain: Optional[str] = Query(None, description="Domain to clear history (e.g. google.com)"),
    start_date: Optional[datetime.datetime] = Query(None, description="Start range to delete"),
    end_date: Optional[datetime.datetime] = Query(None, description="End range to delete"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Bulk delete history matching specific filters (by domain or date ranges).
    """
    stmt = delete(History).where(History.user_id == current_user.id)

    if domain:
        stmt = stmt.where(History.url.ilike(f"%{domain}%"))

    if start_date:
        stmt = stmt.where(History.visit_time >= start_date)

    if end_date:
        stmt = stmt.where(History.visit_time <= end_date)

    result = await db.execute(stmt)
    await db.commit()

    return APIResponse(
        success=True,
        message="Bulk history delete execution completed."
    )


@router.delete("/{history_id}", response_model=APIResponse[None])
async def delete_single_history(
    history_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Deletes a single browsing history record.
    """
    stmt = select(History).where(History.id == history_id, History.user_id == current_user.id)
    res = await db.execute(stmt)
    entry = res.scalars().first()

    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="History entry not found."
        )

    await db.delete(entry)
    await db.commit()

    return APIResponse(
        success=True,
        message="History log entry removed."
    )
