import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.database.session import get_db
from app.database.models import User, BrowserSession, Workspace, TabGroup, Tab
from app.schemas.response import APIResponse
from app.schemas.tabs import (
    WorkspaceCreate,
    WorkspaceResponse,
    TabGroupCreate,
    TabGroupResponse,
    TabCreate,
    TabUpdate,
    TabResponse
)
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/tabs",
    tags=["Tabs & Workspaces"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


# --- WORKSPACES ENDPOINTS ---

@router.post("/workspaces", response_model=APIResponse[WorkspaceResponse], status_code=status.HTTP_201_CREATED)
async def create_workspace(
    body: WorkspaceCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[WorkspaceResponse]:
    """
    Create a new browser workspace for grouping tab sets and profiles.
    """
    workspace = Workspace(
        user_id=current_user.id,
        name=body.name,
        color=body.color,
        icon=body.icon
    )
    db.add(workspace)
    await db.commit()
    await db.refresh(workspace)

    return APIResponse(
        success=True,
        message="Workspace created successfully.",
        data=WorkspaceResponse.model_validate(workspace)
    )


@router.get("/workspaces", response_model=APIResponse[List[WorkspaceResponse]])
async def list_workspaces(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[WorkspaceResponse]]:
    """
    List all workspaces owned by the current user.
    """
    stmt = select(Workspace).where(Workspace.user_id == current_user.id)
    res = await db.execute(stmt)
    workspaces = res.scalars().all()

    return APIResponse(
        success=True,
        message="Workspaces list retrieved.",
        data=[WorkspaceResponse.model_validate(w) for w in workspaces]
    )


# --- TAB GROUPS ENDPOINTS ---

@router.post("/groups", response_model=APIResponse[TabGroupResponse], status_code=status.HTTP_201_CREATED)
async def create_tab_group(
    body: TabGroupCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TabGroupResponse]:
    """
    Create a color-coded tab group under an optional workspace.
    """
    if body.workspace_id:
        # Verify workspace ownership
        w_stmt = select(Workspace).where(Workspace.id == body.workspace_id, Workspace.user_id == current_user.id)
        w_res = await db.execute(w_stmt)
        if not w_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found.")

    group = TabGroup(
        workspace_id=body.workspace_id,
        title=body.title,
        color=body.color,
        is_collapsed=False
    )
    db.add(group)
    await db.commit()
    await db.refresh(group)

    return APIResponse(
        success=True,
        message="Tab group created successfully.",
        data=TabGroupResponse.model_validate(group)
    )


@router.get("/groups", response_model=APIResponse[List[TabGroupResponse]])
async def list_tab_groups(
    workspace_id: Optional[uuid.UUID] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[TabGroupResponse]]:
    """
    List tab groups, optionally filtered by workspace_id.
    """
    if workspace_id:
        # Check workspace ownership first
        w_stmt = select(Workspace).where(Workspace.id == workspace_id, Workspace.user_id == current_user.id)
        w_res = await db.execute(w_stmt)
        if not w_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found.")
        
        stmt = select(TabGroup).where(TabGroup.workspace_id == workspace_id)
    else:
        # Return all tab groups belonging to any of user's workspaces or floating groups
        stmt = (
            select(TabGroup)
            .outerjoin(Workspace, TabGroup.workspace_id == Workspace.id)
            .where((Workspace.user_id == current_user.id) | (TabGroup.workspace_id == None))
        )

    res = await db.execute(stmt)
    groups = res.scalars().all()

    return APIResponse(
        success=True,
        message="Tab groups list retrieved.",
        data=[TabGroupResponse.model_validate(g) for g in groups]
    )


# --- TABS ENDPOINTS ---

@router.post("", response_model=APIResponse[TabResponse], status_code=status.HTTP_201_CREATED)
async def create_tab(
    body: TabCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TabResponse]:
    """
    Record a new tab state in the browser session.
    """
    # Verify session ownership
    sess_stmt = select(BrowserSession).where(BrowserSession.id == body.session_id, BrowserSession.user_id == current_user.id)
    sess_res = await db.execute(sess_stmt)
    if not sess_res.scalars().first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Active browser session not found.")

    if body.tab_group_id:
        # Verify tab group exists
        grp_stmt = select(TabGroup).where(TabGroup.id == body.tab_group_id)
        grp_res = await db.execute(grp_stmt)
        if not grp_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tab group not found.")

    tab = Tab(
        session_id=body.session_id,
        tab_group_id=body.tab_group_id,
        title=body.title,
        url=body.url,
        favicon_url=body.favicon_url,
        pinned=body.pinned,
        active=body.active,
        position=body.position
    )
    db.add(tab)
    await db.commit()
    await db.refresh(tab)

    return APIResponse(
        success=True,
        message="Tab entry registered.",
        data=TabResponse.model_validate(tab)
    )


@router.get("", response_model=APIResponse[List[TabResponse]])
async def get_session_tabs(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[TabResponse]]:
    """
    Retrieve all tabs belonging to a specific browser session.
    """
    # Verify session ownership
    sess_stmt = select(BrowserSession).where(BrowserSession.id == session_id, BrowserSession.user_id == current_user.id)
    sess_res = await db.execute(sess_stmt)
    if not sess_res.scalars().first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Browser session not found.")

    stmt = select(Tab).where(Tab.session_id == session_id).order_by(Tab.position.asc())
    res = await db.execute(stmt)
    tabs = res.scalars().all()

    return APIResponse(
        success=True,
        message="Session tabs retrieved.",
        data=[TabResponse.model_validate(t) for t in tabs]
    )


@router.put("/{tab_id}", response_model=APIResponse[TabResponse])
async def update_tab(
    tab_id: uuid.UUID,
    body: TabUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TabResponse]:
    """
    Update a tab state (pinned, active status, group parent or URL).
    """
    stmt = (
        select(Tab)
        .join(BrowserSession, Tab.session_id == BrowserSession.id)
        .where(Tab.id == tab_id, BrowserSession.user_id == current_user.id)
    )
    res = await db.execute(stmt)
    tab = res.scalars().first()

    if not tab:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tab not found.")

    update_data = body.model_dump(exclude_unset=True)
    
    if "tab_group_id" in update_data and update_data["tab_group_id"]:
        # Verify tab group existence
        grp_stmt = select(TabGroup).where(TabGroup.id == update_data["tab_group_id"])
        grp_res = await db.execute(grp_stmt)
        if not grp_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tab group not found.")

    for key, val in update_data.items():
        setattr(tab, key, val)

    await db.commit()
    await db.refresh(tab)

    return APIResponse(
        success=True,
        message="Tab updated successfully.",
        data=TabResponse.model_validate(tab)
    )


@router.delete("/{tab_id}", response_model=APIResponse[None])
async def close_tab(
    tab_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Close a browser tab and remove it from backend state tracking.
    """
    stmt = (
        select(Tab)
        .join(BrowserSession, Tab.session_id == BrowserSession.id)
        .where(Tab.id == tab_id, BrowserSession.user_id == current_user.id)
    )
    res = await db.execute(stmt)
    tab = res.scalars().first()

    if not tab:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tab not found.")

    await db.delete(tab)
    await db.commit()

    return APIResponse(
        success=True,
        message="Tab closed successfully."
    )
