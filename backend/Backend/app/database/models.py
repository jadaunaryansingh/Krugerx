import uuid
import datetime
from typing import List, Optional, Dict, Any
from sqlalchemy import DateTime, ForeignKey, String, Integer, Float, Boolean, Text, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class BaseModel(Base):
    """
    Base model class that automatically adds uuid primary key,
    created_at, updated_at, and soft delete deleted_at fields.
    """
    __abstract__ = True

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now()
    )
    updated_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )
    deleted_at: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )


class User(BaseModel):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Relationships
    profile: Mapped[Optional["Profile"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    settings: Mapped[Optional["Setting"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    devices: Mapped[List["Device"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    browser_sessions: Mapped[List["BrowserSession"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    folders: Mapped[List["Folder"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    bookmarks: Mapped[List["Bookmark"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    history_entries: Mapped[List["History"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    search_histories: Mapped[List["SearchHistory"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    downloads: Mapped[List["Download"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    collections: Mapped[List["Collection"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    ai_sessions: Mapped[List["AISession"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    notifications: Mapped[List["Notification"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    activity_logs: Mapped[List["ActivityLog"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    sync_items: Mapped[List["SyncQueue"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    feedback_entries: Mapped[List["Feedback"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    crash_reports: Mapped[List["CrashReport"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    workspaces: Mapped[List["Workspace"]] = relationship(back_populates="user", cascade="all, delete-orphan")


class Profile(BaseModel):
    __tablename__ = "profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), unique=True, nullable=False)
    display_name: Mapped[Optional[str]] = mapped_column(String(100))
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500))

    user: Mapped["User"] = relationship(back_populates="profile")


class Device(BaseModel):
    __tablename__ = "devices"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    device_name: Mapped[str] = mapped_column(String(100), nullable=False)
    device_type: Mapped[str] = mapped_column(String(50), nullable=False)  # desktop, mobile, tablet
    os: Mapped[str] = mapped_column(String(50), nullable=False)
    client_version: Mapped[str] = mapped_column(String(50), nullable=False)
    push_token: Mapped[Optional[str]] = mapped_column(String(500))
    last_active_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user: Mapped["User"] = relationship(back_populates="devices")
    browser_sessions: Mapped[List["BrowserSession"]] = relationship(back_populates="device")


class Setting(BaseModel):
    __tablename__ = "settings"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), unique=True, nullable=False)
    theme: Mapped[str] = mapped_column(String(50), default="system")
    search_engine: Mapped[str] = mapped_column(String(50), default="google")
    homepage_url: Mapped[str] = mapped_column(String(500), default="https://google.com")
    language: Mapped[str] = mapped_column(String(10), default="en")
    font_size: Mapped[int] = mapped_column(Integer, default=14)
    privacy_tracking_protection: Mapped[bool] = mapped_column(Boolean, default=True)
    ai_provider: Mapped[str] = mapped_column(String(50), default="openai")
    ai_model: Mapped[str] = mapped_column(String(100), default="gpt-4o")

    user: Mapped["User"] = relationship(back_populates="settings")


class BrowserSession(BaseModel):
    __tablename__ = "browser_sessions"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    device_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("devices.id", ondelete="SET NULL"))
    profile_name: Mapped[str] = mapped_column(String(100), default="Default")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    user: Mapped["User"] = relationship(back_populates="browser_sessions")
    device: Mapped[Optional["Device"]] = relationship(back_populates="browser_sessions")
    tabs: Mapped[List["Tab"]] = relationship(back_populates="session", cascade="all, delete-orphan")


class Workspace(BaseModel):
    __tablename__ = "workspaces"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    color: Mapped[Optional[str]] = mapped_column(String(20))
    icon: Mapped[Optional[str]] = mapped_column(String(50))

    user: Mapped["User"] = relationship(back_populates="workspaces")
    tab_groups: Mapped[List["TabGroup"]] = relationship(back_populates="workspace", cascade="all, delete-orphan")


class TabGroup(BaseModel):
    __tablename__ = "tab_groups"

    workspace_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("workspaces.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String(100), nullable=False)
    color: Mapped[Optional[str]] = mapped_column(String(20))
    is_collapsed: Mapped[bool] = mapped_column(Boolean, default=False)

    workspace: Mapped[Optional["Workspace"]] = relationship(back_populates="tab_groups")
    tabs: Mapped[List["Tab"]] = relationship(back_populates="tab_group", cascade="all, delete-orphan")


class Tab(BaseModel):
    __tablename__ = "tabs"

    session_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("browser_sessions.id", ondelete="CASCADE"), nullable=False)
    tab_group_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("tab_groups.id", ondelete="SET NULL"))
    title: Mapped[Optional[str]] = mapped_column(String(500))
    url: Mapped[str] = mapped_column(Text, nullable=False)
    favicon_url: Mapped[Optional[str]] = mapped_column(String(1000))
    pinned: Mapped[bool] = mapped_column(Boolean, default=False)
    active: Mapped[bool] = mapped_column(Boolean, default=False)
    position: Mapped[int] = mapped_column(Integer, default=0)

    session: Mapped["BrowserSession"] = relationship(back_populates="tabs")
    tab_group: Mapped[Optional["TabGroup"]] = relationship(back_populates="tabs")


class Folder(BaseModel):
    __tablename__ = "folders"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    parent_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("folders.id", ondelete="CASCADE"))
    name: Mapped[str] = mapped_column(String(255), nullable=False)

    user: Mapped["User"] = relationship(back_populates="folders")
    subfolders: Mapped[List["Folder"]] = relationship(
        "Folder", back_populates="parent", cascade="all, delete-orphan"
    )
    parent: Mapped[Optional["Folder"]] = relationship("Folder", back_populates="subfolders", remote_side="Folder.id")
    bookmarks: Mapped[List["Bookmark"]] = relationship(back_populates="folder", cascade="all, delete-orphan")


class Bookmark(BaseModel):
    __tablename__ = "bookmarks"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    folder_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("folders.id", ondelete="SET NULL"))
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    url: Mapped[str] = mapped_column(Text, nullable=False)
    position: Mapped[int] = mapped_column(Integer, default=0)

    user: Mapped["User"] = relationship(back_populates="bookmarks")
    folder: Mapped[Optional["Folder"]] = relationship(back_populates="bookmarks")


class History(BaseModel):
    __tablename__ = "history"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    device_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("devices.id", ondelete="SET NULL"))
    url: Mapped[str] = mapped_column(Text, nullable=False)
    title: Mapped[Optional[str]] = mapped_column(String(500))
    visit_time: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    visit_count: Mapped[int] = mapped_column(Integer, default=1)

    user: Mapped["User"] = relationship(back_populates="history_entries")


class SearchHistory(BaseModel):
    __tablename__ = "search_history"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    query: Mapped[str] = mapped_column(String(500), nullable=False)
    engine: Mapped[str] = mapped_column(String(50), nullable=False)

    user: Mapped["User"] = relationship(back_populates="search_histories")


class Download(BaseModel):
    __tablename__ = "downloads"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    filename: Mapped[str] = mapped_column(String(255), nullable=False)
    url: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[str] = mapped_column(String(50), default="queued")  # queued, downloading, completed, failed, cancelled
    progress: Mapped[float] = mapped_column(Float, default=0.0)
    total_bytes: Mapped[Optional[int]] = mapped_column(Integer)
    downloaded_bytes: Mapped[Optional[int]] = mapped_column(Integer)
    completed_time: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))

    user: Mapped["User"] = relationship(back_populates="downloads")


class Collection(BaseModel):
    __tablename__ = "collections"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text)

    user: Mapped["User"] = relationship(back_populates="collections")
    items: Mapped[List["CollectionItem"]] = relationship(back_populates="collection", cascade="all, delete-orphan")


class CollectionItem(BaseModel):
    __tablename__ = "collection_items"

    collection_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("collections.id", ondelete="CASCADE"), nullable=False)
    title: Mapped[Optional[str]] = mapped_column(String(500))
    url: Mapped[str] = mapped_column(Text, nullable=False)
    notes: Mapped[Optional[str]] = mapped_column(Text)

    collection: Mapped["Collection"] = relationship(back_populates="items")


class AISession(BaseModel):
    __tablename__ = "ai_sessions"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    provider: Mapped[str] = mapped_column(String(50), nullable=False)
    model: Mapped[str] = mapped_column(String(100), nullable=False)

    user: Mapped["User"] = relationship(back_populates="ai_sessions")
    conversations: Mapped[List["AIConversation"]] = relationship(back_populates="session", cascade="all, delete-orphan")


class AIConversation(BaseModel):
    __tablename__ = "ai_conversations"

    session_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("ai_sessions.id", ondelete="CASCADE"), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)

    session: Mapped["AISession"] = relationship(back_populates="conversations")
    messages: Mapped[List["AIMessage"]] = relationship(back_populates="conversation", cascade="all, delete-orphan")


class AIMessage(BaseModel):
    __tablename__ = "ai_messages"

    conversation_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("ai_conversations.id", ondelete="CASCADE"), nullable=False)
    role: Mapped[str] = mapped_column(String(50), nullable=False)  # system, user, assistant
    content: Mapped[str] = mapped_column(Text, nullable=False)
    token_count: Mapped[Optional[int]] = mapped_column(Integer)
    metadata_json: Mapped[Optional[Dict[str, Any]]] = mapped_column(JSONB)

    conversation: Mapped["AIConversation"] = relationship(back_populates="messages")


class Notification(BaseModel):
    __tablename__ = "notifications"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False)  # sync, alert, system

    user: Mapped["User"] = relationship(back_populates="notifications")


class ActivityLog(BaseModel):
    __tablename__ = "activity_logs"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    action: Mapped[str] = mapped_column(String(100), nullable=False)
    ip_address: Mapped[Optional[str]] = mapped_column(String(45))
    user_agent: Mapped[Optional[str]] = mapped_column(String(500))

    user: Mapped["User"] = relationship(back_populates="activity_logs")


class SyncQueue(BaseModel):
    __tablename__ = "sync_queue"

    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE", onupdate="CASCADE"), nullable=False)
    device_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("devices.id", ondelete="SET NULL"))
    entity_type: Mapped[str] = mapped_column(String(50), nullable=False)  # bookmark, history, setting, tab, collection
    entity_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    action: Mapped[str] = mapped_column(String(50), nullable=False)  # create, update, delete
    payload: Mapped[Optional[Dict[str, Any]]] = mapped_column(JSONB)
    synced_at: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime(timezone=True))

    user: Mapped["User"] = relationship(back_populates="sync_items")


class Feedback(BaseModel):
    __tablename__ = "feedback"

    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    rating: Mapped[int] = mapped_column(Integer, nullable=False)
    comment: Mapped[Optional[str]] = mapped_column(Text)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # crash, feature, general

    user: Mapped[Optional["User"]] = relationship(back_populates="feedback_entries")


class CrashReport(BaseModel):
    __tablename__ = "crash_reports"

    user_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    device_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("devices.id", ondelete="SET NULL"))
    stack_trace: Mapped[str] = mapped_column(Text, nullable=False)
    app_version: Mapped[str] = mapped_column(String(50), nullable=False)
    os_version: Mapped[str] = mapped_column(String(50), nullable=False)
    metadata_json: Mapped[Optional[Dict[str, Any]]] = mapped_column(JSONB)

    user: Mapped[Optional["User"]] = relationship(back_populates="crash_reports")
