import pytest
import pytest_asyncio
from typing import AsyncGenerator, Generator
from unittest.mock import AsyncMock, MagicMock
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession

from main import app
from app.database.session import get_db
from app.dependencies.auth import get_current_user
from app.database.models import User, Profile, Setting
from app.dependencies.rate_limiter import check_rate_limit


# 1. Override dependencies to disable rate limiter during testing
async def override_rate_limit():
    pass

app.dependency_overrides[check_rate_limit] = override_rate_limit


@pytest.fixture
def mock_db_session(mock_user: User) -> MagicMock:
    """
    Creates a Mock database session wrapper.
    """
    session = MagicMock(spec=AsyncSession)
    
    # Track added objects to assign mock attributes
    def fake_add(instance):
        import uuid
        import datetime
        if hasattr(instance, "id") and instance.id is None:
            instance.id = uuid.uuid4()
        if hasattr(instance, "user_id") and getattr(instance, "user_id", None) is None:
            instance.user_id = mock_user.id
        if hasattr(instance, "created_at") and instance.created_at is None:
            instance.created_at = datetime.datetime.now(datetime.timezone.utc)
        if hasattr(instance, "updated_at") and instance.updated_at is None:
            instance.updated_at = datetime.datetime.now(datetime.timezone.utc)
        if hasattr(instance, "position") and getattr(instance, "position", None) is None:
            instance.position = 0
        if hasattr(instance, "visit_time") and instance.visit_time is None:
            instance.visit_time = datetime.datetime.now(datetime.timezone.utc)
        if hasattr(instance, "visit_count") and getattr(instance, "visit_count", None) is None:
            instance.visit_count = 1
        if hasattr(instance, "theme") and getattr(instance, "theme", None) is None:
            instance.theme = "system"
        if hasattr(instance, "search_engine") and getattr(instance, "search_engine", None) is None:
            instance.search_engine = "google"
        if hasattr(instance, "homepage_url") and getattr(instance, "homepage_url", None) is None:
            instance.homepage_url = "https://google.com"
        if hasattr(instance, "language") and getattr(instance, "language", None) is None:
            instance.language = "en"
        if hasattr(instance, "font_size") and getattr(instance, "font_size", None) is None:
            instance.font_size = 14
        if hasattr(instance, "privacy_tracking_protection") and getattr(instance, "privacy_tracking_protection", None) is None:
            instance.privacy_tracking_protection = True
        if hasattr(instance, "ai_provider") and getattr(instance, "ai_provider", None) is None:
            instance.ai_provider = "openai"
        if hasattr(instance, "ai_model") and getattr(instance, "ai_model", None) is None:
            instance.ai_model = "gpt-4o"

    session.add = MagicMock(side_effect=fake_add)
    
    # Stub async database methods
    session.commit = AsyncMock()
    session.rollback = AsyncMock()
    session.flush = AsyncMock()
    session.refresh = AsyncMock()
    session.delete = AsyncMock()
    
    # Stub execute to return chainable mocks for queries
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = mock_user
    mock_result.scalars.return_value.all.return_value = [mock_user]
    session.execute = AsyncMock(return_value=mock_result)
    
    return session


@pytest.fixture
def mock_user() -> User:
    """
    Fixture returning a test database user model.
    """
    import uuid
    user_id = uuid.uuid4()
    user = User(
        id=user_id,
        email="test_user@krugerx-browser.local",
        is_active=True
    )
    user.profile = Profile(
        id=uuid.uuid4(),
        user_id=user_id,
        display_name="Test User"
    )
    user.settings = Setting(
        id=uuid.uuid4(),
        user_id=user_id,
        theme="dark",
        search_engine="google",
        homepage_url="https://google.com",
        language="en",
        font_size=14,
        privacy_tracking_protection=True,
        ai_provider="openai",
        ai_model="gpt-4o"
    )
    return user


@pytest.fixture
def client(mock_db_session: MagicMock, mock_user: User) -> Generator[TestClient, None, None]:
    """
    Returns FastAPI test client with mocked DB session and Auth dependency overrides.
    """
    async def override_get_db() -> AsyncGenerator[AsyncSession, None]:
        yield mock_db_session

    async def override_get_current_user() -> User:
        return mock_user

    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_current_user] = override_get_current_user

    with TestClient(app) as test_client:
        yield test_client
    
    # Cleanup dependency overrides
    app.dependency_overrides.pop(get_db, None)
    app.dependency_overrides.pop(get_current_user, None)
