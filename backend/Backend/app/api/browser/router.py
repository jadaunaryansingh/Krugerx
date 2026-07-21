import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database.session import get_db
from app.database.models import User, BrowserSession, Device
from app.schemas.response import APIResponse
from app.schemas.browser import (
    BrowserSessionCreate,
    BrowserSessionResponse,
    ExtensionRegisterRequest,
    ExtensionResponse
)
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/browser",
    tags=["Browser Profiles & Extensions"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


# --- BROWSER SESSIONS ---

@router.post("/sessions", response_model=APIResponse[BrowserSessionResponse], status_code=status.HTTP_201_CREATED)
async def start_session(
    body: BrowserSessionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[BrowserSessionResponse]:
    """
    Start tracking a new browser window/profile session.
    """
    # Verify device exists and belongs to user
    dev_stmt = select(Device).where(Device.id == body.device_id, Device.user_id == current_user.id)
    dev_res = await db.execute(dev_stmt)
    if not dev_res.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Registered device not found."
        )

    # Deactivate other active sessions on this device for the same profile
    deact_stmt = select(BrowserSession).where(
        BrowserSession.device_id == body.device_id,
        BrowserSession.profile_name == body.profile_name,
        BrowserSession.is_active == True
    )
    deact_res = await db.execute(deact_stmt)
    for active_sess in deact_res.scalars().all():
        active_sess.is_active = False

    session = BrowserSession(
        user_id=current_user.id,
        device_id=body.device_id,
        profile_name=body.profile_name,
        is_active=True
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)

    return APIResponse(
        success=True,
        message="Browser session started successfully.",
        data=BrowserSessionResponse.model_validate(session)
    )


@router.get("/sessions", response_model=APIResponse[List[BrowserSessionResponse]])
async def list_active_sessions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[BrowserSessionResponse]]:
    """
    List all active browser sessions across the user's devices.
    """
    stmt = select(BrowserSession).where(
        BrowserSession.user_id == current_user.id,
        BrowserSession.is_active == True
    )
    res = await db.execute(stmt)
    sessions = res.scalars().all()

    return APIResponse(
        success=True,
        message="Active browser sessions retrieved.",
        data=[BrowserSessionResponse.model_validate(s) for s in sessions]
    )


@router.delete("/sessions/{session_id}", response_model=APIResponse[None])
async def close_session(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Terminate a browser session tracking instance.
    """
    stmt = select(BrowserSession).where(BrowserSession.id == session_id, BrowserSession.user_id == current_user.id)
    res = await db.execute(stmt)
    session = res.scalars().first()

    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Browser session record not found."
        )

    session.is_active = False
    await db.commit()

    return APIResponse(
        success=True,
        message="Browser session closed."
    )


# --- EXTENSION MANAGEMENT API ---

# Simulated global list in Redis/DB of installed extensions per profile (mocked/simulated storage representation)
MOCK_EXTENSIONS: List[ExtensionResponse] = [
    ExtensionResponse(extension_id="cjpalhdlnbpafiamejdnhcphjbkeiagm", name="uBlock Origin", version="1.58.0", enabled=True),
    ExtensionResponse(extension_id="nngceckbapebfimnlniiiahkandcljfg", name="Grammarly AI writing assistant", version="14.1160.0", enabled=True)
]


@router.get("/extensions", response_model=APIResponse[List[ExtensionResponse]])
async def list_installed_extensions(
    current_user: User = Depends(get_current_user)
) -> APIResponse[List[ExtensionResponse]]:
    """
    List extensions installed inside this browser profile context.
    """
    return APIResponse(
        success=True,
        message="Extensions loaded successfully.",
        data=MOCK_EXTENSIONS
    )


@router.post("/extensions", response_model=APIResponse[ExtensionResponse])
async def install_extension(
    body: ExtensionRegisterRequest,
    current_user: User = Depends(get_current_user)
) -> APIResponse[ExtensionResponse]:
    """
    Register or activate a browser extension.
    """
    new_ext = ExtensionResponse(
        extension_id=body.extension_id,
        name=body.name,
        version=body.version,
        enabled=body.enabled
    )
    # Check if exists and update, else append
    for idx, ext in enumerate(MOCK_EXTENSIONS):
        if ext.extension_id == body.extension_id:
            MOCK_EXTENSIONS[idx] = new_ext
            return APIResponse(success=True, message="Extension configuration updated.", data=new_ext)

    MOCK_EXTENSIONS.append(new_ext)
    return APIResponse(
        success=True,
        message="Extension registered successfully.",
        data=new_ext
    )


@router.delete("/extensions/{extension_id}", response_model=APIResponse[None])
async def uninstall_extension(
    extension_id: str,
    current_user: User = Depends(get_current_user)
) -> APIResponse[None]:
    """
    Uninstall/deregister an extension from the browser configuration.
    """
    for ext in MOCK_EXTENSIONS:
        if ext.extension_id == extension_id:
            MOCK_EXTENSIONS.remove(ext)
            return APIResponse(success=True, message="Extension uninstalled successfully.")

    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Extension not found."
    )
