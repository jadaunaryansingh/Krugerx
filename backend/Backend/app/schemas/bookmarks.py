import uuid
from typing import List, Optional
from pydantic import BaseModel, HttpUrl, Field


class BookmarkBase(BaseModel):
    title: str = Field(..., max_length=500)
    url: str = Field(..., description="Destination URL of the bookmark")
    folder_id: Optional[uuid.UUID] = None
    position: int = 0


class BookmarkCreate(BookmarkBase):
    pass


class BookmarkUpdate(BaseModel):
    title: Optional[str] = Field(None, max_length=500)
    url: Optional[str] = None
    folder_id: Optional[uuid.UUID] = None
    position: Optional[int] = None


class BookmarkResponse(BookmarkBase):
    id: uuid.UUID
    user_id: uuid.UUID

    class Config:
        from_attributes = True


class FolderBase(BaseModel):
    name: str = Field(..., max_length=255)
    parent_id: Optional[uuid.UUID] = None


class FolderCreate(FolderBase):
    pass


class FolderUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    parent_id: Optional[uuid.UUID] = None


# Define forward references to handle nested folders cleanly in Pydantic v2
class FolderTreeResponse(BaseModel):
    id: uuid.UUID
    name: str
    parent_id: Optional[uuid.UUID] = None
    subfolders: List["FolderTreeResponse"] = []
    bookmarks: List[BookmarkResponse] = []

    class Config:
        from_attributes = True
