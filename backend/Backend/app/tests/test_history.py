import uuid
import datetime
from fastapi.testclient import TestClient
from unittest.mock import MagicMock
from app.database.models import History


def test_record_visit(client: TestClient, mock_db_session: MagicMock) -> None:
    """
    Validate logging browsing history entries.
    """
    payload = {
        "url": "https://wikipedia.org",
        "title": "Wikipedia Encyclopedia"
    }

    # Mock no recent entries
    mock_result = MagicMock()
    mock_result.scalars = MagicMock(return_value=MagicMock(first=MagicMock(return_value=None)))
    mock_db_session.execute.return_value = mock_result

    response = client.post("/api/v1/history", json=payload)
    assert response.status_code == 201
    
    data = response.json()
    assert data["success"] is True
    assert data["data"]["url"] == "https://wikipedia.org"


def test_bulk_delete_history(client: TestClient, mock_db_session: MagicMock) -> None:
    """
    Validate clearing logs via query parameters.
    """
    response = client.delete("/api/v1/history/bulk?domain=wikipedia.org")
    assert response.status_code == 200
    assert response.json()["success"] is True
