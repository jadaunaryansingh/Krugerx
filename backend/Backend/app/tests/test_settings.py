from fastapi.testclient import TestClient
from unittest.mock import MagicMock
from app.database.models import Setting


def test_get_settings(client: TestClient, mock_db_session: MagicMock) -> None:
    """
    Validate loading default configuration items.
    """
    mock_setting = Setting(
        theme="light",
        search_engine="bing",
        homepage_url="https://bing.com",
        language="en",
        font_size=14,
        privacy_tracking_protection=True,
        ai_provider="openai",
        ai_model="gpt-4o"
    )
    
    mock_result = MagicMock()
    mock_result.scalars = MagicMock(return_value=MagicMock(first=MagicMock(return_value=mock_setting)))
    mock_db_session.execute.return_value = mock_result

    response = client.get("/api/v1/settings")
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    assert data["data"]["theme"] == "light"
    assert data["data"]["search_engine"] == "bing"


def test_update_settings(client: TestClient, mock_db_session: MagicMock) -> None:
    """
    Validate updating browser settings.
    """
    mock_setting = Setting(
        theme="light",
        search_engine="google",
        homepage_url="https://google.com",
        language="en",
        font_size=14,
        privacy_tracking_protection=True,
        ai_provider="openai",
        ai_model="gpt-4o"
    )
    
    mock_result = MagicMock()
    mock_result.scalars = MagicMock(return_value=MagicMock(first=MagicMock(return_value=mock_setting)))
    mock_db_session.execute.return_value = mock_result

    payload = {"theme": "dark", "search_engine": "brave"}
    response = client.put("/api/v1/settings", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["data"]["theme"] == "dark"
