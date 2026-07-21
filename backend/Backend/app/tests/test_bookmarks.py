import uuid
from fastapi.testclient import TestClient
from unittest.mock import MagicMock, AsyncMock
from sqlalchemy.future import select
from app.database.models import Bookmark


def test_create_bookmark(client: TestClient, mock_db_session: MagicMock) -> None:
    """
    Validate posting bookmark metadata.
    """
    payload = {
        "title": "Krugerx Home",
        "url": "https://krugerx.io",
        "position": 1
    }
    
    response = client.post("/api/v1/bookmarks", json=payload)
    assert response.status_code == 201
    
    data = response.json()
    assert data["success"] is True
    assert data["data"]["title"] == "Krugerx Home"
    assert data["data"]["url"] == "https://krugerx.io"


def test_get_bookmarks_list(client: TestClient, mock_db_session: MagicMock) -> None:
    """
    Validate loading bookmark registers.
    """
    mock_bookmark = Bookmark(
        id=uuid.uuid4(),
        user_id=uuid.uuid4(),
        title="Google Search",
        url="https://google.com",
        position=1
    )
    
    # Mock database session execution scalars
    mock_result = MagicMock()
    mock_result.scalars = MagicMock(return_value=MagicMock(all=MagicMock(return_value=[mock_bookmark])))
    mock_db_session.execute.return_value = mock_result

    response = client.get("/api/v1/bookmarks")
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    assert len(data["data"]) == 1
    assert data["data"][0]["title"] == "Google Search"
