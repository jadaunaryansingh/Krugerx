from typing import Dict, List
from fastapi import WebSocket
from loguru import logger
import json


class WebSocketConnectionManager:
    """
    Manager class responsible for holding active WebSocket client channels
    and handling real-time push notifications.
    """
    def __init__(self) -> None:
        # Map user_id to list of active WebSocket sessions
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, user_id: str, websocket: WebSocket) -> None:
        """
        Accepts the websocket connection and registers it under user ID.
        """
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)
        logger.info(f"WebSocket client connected for user {user_id}. Active sessions: {len(self.active_connections[user_id])}")

    def disconnect(self, user_id: str, websocket: WebSocket) -> None:
        """
        Removes the websocket from the active connections registry.
        """
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        logger.info(f"WebSocket client disconnected for user {user_id}.")

    async def send_personal_message(self, message: dict, websocket: WebSocket) -> None:
        """
        Send a payload to a specific socket connection.
        """
        await websocket.send_text(json.dumps(message))

    async def broadcast_to_user(self, user_id: str, message: dict) -> None:
        """
        Sends a real-time event to all active sockets logged in with the given user_id.
        Useful for multi-device sync and notifications.
        """
        connections = self.active_connections.get(user_id, [])
        if not connections:
            return

        payload = json.dumps(message)
        disconnected_sockets = []

        for socket in connections:
            try:
                await socket.send_text(payload)
            except Exception as e:
                logger.bind(category="errors").warning(f"Failed to send websocket update: {str(e)}")
                disconnected_sockets.append(socket)

        # Cleanup dead sockets
        for socket in disconnected_sockets:
            self.disconnect(user_id, socket)


# Global connection manager instance
ws_manager = WebSocketConnectionManager()
