import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query, status
from loguru import logger
import uuid

from app.core.jwt import verify_supabase_token
from app.websocket.connection_manager import ws_manager

router = APIRouter(
    prefix="/ws",
    tags=["Realtime WebSockets"]
)


@router.websocket("")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(..., description="Supabase Auth JWT Token for validation")
) -> None:
    """
    Establish a WebSocket connection. Authenticates the client JWT via query parameters
    and keeps the channel open for realtime event broadcasts (notifications, sync events, progress).
    """
    # 1. Authenticate Token
    try:
        payload = verify_supabase_token(token)
        user_id_str = payload.get("sub")
        if not user_id_str:
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason="Invalid token claims.")
            return
        user_id = str(uuid.UUID(user_id_str))
    except Exception as e:
        logger.bind(category="security").warning(f"WebSocket auth failed: {str(e)}")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION, reason="Authentication failed.")
        return

    # 2. Register socket with manager
    await ws_manager.connect(user_id, websocket)

    try:
        # Keep channel alive and listen for ping/pong or client messages
        while True:
            raw_data = await websocket.receive_text()
            try:
                data = json.loads(raw_data)
                
                # Check for ping event to maintain keep-alive
                if data.get("type") == "ping":
                    await websocket.send_text(json.dumps({"type": "pong"}))
                    continue

                logger.info(f"Received message from client {user_id}: {data}")
                
            except json.JSONDecodeError:
                await websocket.send_text(json.dumps({
                    "success": False,
                    "message": "Malformed message format. Expected JSON."
                }))

    except WebSocketDisconnect:
        ws_manager.disconnect(user_id, websocket)
    except Exception as e:
        logger.bind(category="errors").error(f"WebSocket error in user session {user_id}: {str(e)}")
        ws_manager.disconnect(user_id, websocket)
