from fastapi.testclient import TestClient
from unittest.mock import MagicMock
from app.database.models import User


def test_get_current_user_profile(client: TestClient, mock_user: User) -> None:
    """
    Test pulling user profile via /auth/me.
    """
    response = client.get("/api/v1/auth/me")
    assert response.status_code == 200
    
    data = response.json()
    assert data["success"] is True
    assert data["data"]["email"] == mock_user.email
    assert data["data"]["profile"]["display_name"] == mock_user.profile.display_name


def test_logout_endpoint(client: TestClient) -> None:
    """
    Test logging out invalidates headers.
    """
    # Mock auth_service.logout in router
    from unittest.mock import patch
    from unittest.mock import AsyncMock
    with patch("app.api.auth.router.auth_service.logout", new_callable=AsyncMock) as mock_logout:
        response = client.post("/api/v1/auth/logout", headers={"Authorization": "Bearer fake_token"})
        assert response.status_code == 200
        assert response.json()["success"] is True
