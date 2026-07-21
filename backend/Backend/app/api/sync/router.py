import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database.session import get_db
from app.database.models import User, Device, SyncQueue
from app.schemas.response import APIResponse
from app.schemas.sync import (
    DeviceRegisterRequest,
    DeviceResponse,
    SyncItemRequest,
    SyncItemResponse,
    SyncPullResponse
)
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/sync",
    tags=["Cloud Sync"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


# --- DEVICES ENDPOINTS ---

@router.post("/devices", response_model=APIResponse[DeviceResponse])
async def register_device(
    body: DeviceRegisterRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[DeviceResponse]:
    """
    Registers the browser client device or updates active status if already existing.
    """
    # Check if a device with the same name and OS exists for the user
    stmt = select(Device).where(
        Device.user_id == current_user.id,
        Device.device_name == body.device_name,
        Device.os == body.os
    )
    res = await db.execute(stmt)
    device = res.scalars().first()

    if device:
        # Update existing device info
        device.client_version = body.client_version
        device.push_token = body.push_token
        device.last_active_at = datetime.datetime.now(datetime.timezone.utc)
    else:
        # Create new device record
        device = Device(
            user_id=current_user.id,
            device_name=body.device_name,
            device_type=body.device_type,
            os=body.os,
            client_version=body.client_version,
            push_token=body.push_token,
            last_active_at=datetime.datetime.now(datetime.timezone.utc)
        )
        db.add(device)

    await db.commit()
    await db.refresh(device)

    return APIResponse(
        success=True,
        message="Device registered successfully.",
        data=DeviceResponse.model_validate(device)
    )


@router.get("/devices", response_model=APIResponse[List[DeviceResponse]])
async def list_devices(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[DeviceResponse]]:
    """
    Retrieves all devices registered to the current user.
    """
    stmt = select(Device).where(Device.user_id == current_user.id).order_by(Device.last_active_at.desc())
    res = await db.execute(stmt)
    devices = res.scalars().all()

    return APIResponse(
        success=True,
        message="Devices retrieved.",
        data=[DeviceResponse.model_validate(d) for d in devices]
    )


@router.delete("/devices/{device_id}", response_model=APIResponse[None])
async def remove_device(
    device_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Unregisters a device and terminates its sync queues.
    """
    stmt = select(Device).where(Device.id == device_id, Device.user_id == current_user.id)
    res = await db.execute(stmt)
    device = res.scalars().first()

    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found.")

    await db.delete(device)
    await db.commit()

    return APIResponse(
        success=True,
        message="Device removed successfully."
    )


# --- SYNC QUEUE ENDPOINTS ---

@router.post("/push", response_model=APIResponse[List[SyncItemResponse]])
async def push_sync_changes(
    body: List[SyncItemRequest],
    device_id: Optional[uuid.UUID] = Query(None, description="Source device ID making changes"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[SyncItemResponse]]:
    """
    Submit local changes from the client to the offline sync queue.
    """
    if device_id:
        # Verify device ownership
        dev_stmt = select(Device).where(Device.id == device_id, Device.user_id == current_user.id)
        dev_res = await db.execute(dev_stmt)
        if not dev_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Registering device not found.")

    sync_entries = []
    for item in body:
        entry = SyncQueue(
            user_id=current_user.id,
            device_id=device_id,
            entity_type=item.entity_type,
            entity_id=item.entity_id,
            action=item.action,
            payload=item.payload
        )
        db.add(entry)
        sync_entries.append(entry)

    await db.commit()
    
    # Refresh to load IDs/timestamps
    for entry in sync_entries:
        await db.refresh(entry)

    return APIResponse(
        success=True,
        message=f"Pushed {len(sync_entries)} mutations to cloud sync queue.",
        data=[SyncItemResponse.model_validate(e) for e in sync_entries]
    )


@router.get("/pull", response_model=APIResponse[SyncPullResponse])
async def pull_sync_changes(
    last_pulled_time: Optional[datetime.datetime] = Query(None, description="Time of last sync pull"),
    device_id: Optional[uuid.UUID] = Query(None, description="Requesting device ID to exclude self-changes"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[SyncPullResponse]:
    """
    Pull pending database state updates. Excludes changes pushed by the requesting device itself.
    """
    stmt = select(SyncQueue).where(SyncQueue.user_id == current_user.id)

    # Exclude changes submitted by the same device
    if device_id:
        stmt = stmt.where((SyncQueue.device_id != device_id) | (SyncQueue.device_id == None))

    # Pull items created/updated after the client's last sync checkpoint
    if last_pulled_time:
        stmt = stmt.where(SyncQueue.created_at > last_pulled_time)

    stmt = stmt.order_by(SyncQueue.created_at.asc())
    res = await db.execute(stmt)
    items = res.scalars().all()

    return APIResponse(
        success=True,
        message="Pending sync queue events retrieved.",
        data=SyncPullResponse(
            queue_items=[SyncItemResponse.model_validate(i) for i in items],
            server_time=datetime.datetime.now(datetime.timezone.utc)
        )
    )


@router.delete("/clear", response_model=APIResponse[None])
async def clear_sync_queue(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Clears all entries in the user's offline sync queue.
    """
    stmt = delete(SyncQueue).where(SyncQueue.user_id == current_user.id)
    await db.execute(stmt)
    await db.commit()

    return APIResponse(
        success=True,
        message="Sync queue successfully purged."
    )
