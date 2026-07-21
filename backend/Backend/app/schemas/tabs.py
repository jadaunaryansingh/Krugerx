import uuid
from typing import Optional, List
from pydantic import BaseModel, Field


class WorkspaceCreate(BaseModel):
    name: str = Field(..., max_length=100)
    color: Optional[str] = Field(None, max_length=20)
    icon: Optional[str] = Field(None, max_length=50)


class WorkspaceResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    name: str
    color: Optional[str] = None
    icon: Optional[str] = None

    class Config:
        from_attributes = True


class TabGroupCreate(BaseModel):
    workspace_id: Optional[uuid.UUID] = None
    title: str = Field(..., max_length=100)
    color: Optional[str] = Field(None, max_length=20)


class TabGroupResponse(BaseModel):
    id: uuid.UUID
    workspace_id: Optional[uuid.UUID] = None
    title: str
    color: Optional[str] = None
    is_collapsed: bool

    class Config:
        from_attributes = True


class TabCreate(BaseModel):
    session_id: uuid.UUID
    tab_group_id: Optional[uuid.UUID] = None
    title: Optional[str] = Field(None, max_length=500)
    url: str
    favicon_url: Optional[str] = Field(None, max_length=1000)
    pinned: bool = False
    active: bool = False
    position: int = 0


class TabUpdate(BaseModel):
    tab_group_id: Optional[uuid.UUID] = None
    title: Optional[str] = Field(None, max_length=500)
    url: Optional[str] = None
    favicon_url: Optional[str] = Field(None, max_length=1000)
    pinned: Optional[bool] = None
    active: Optional[bool] = None
    position: Optional[int] = None


class TabResponse(BaseModel):
    id: uuid.UUID
    session_id: uuid.UUID
    tab_group_id: Optional[uuid.UUID] = None
    title: Optional[str] = None
    url: str
    favicon_url: Optional[str] = None
    pinned: bool
    active: bool
    position: int

    class Config:
        from_attributes = True
