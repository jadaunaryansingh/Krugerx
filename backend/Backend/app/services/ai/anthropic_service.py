import json
import base64
from typing import AsyncGenerator, Dict, Any, List, Optional
import httpx
from loguru import logger

from app.core.config import settings
from app.services.ai.base import BaseAIService


class AnthropicService(BaseAIService):
    """
    Anthropic Claude implementation utilizing direct HTTP endpoints for Messages.
    """
    def __init__(self) -> None:
        self.api_key = settings.ANTHROPIC_API_KEY
        self.base_url = "https://api.anthropic.com/v1"

    def _get_headers(self) -> Dict[str, str]:
        return {
            "x-api-key": self.api_key or "",
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json"
        }

    def _extract_system_and_messages(self, messages: List[Dict[str, str]]) -> tuple[Optional[str], List[Dict[str, str]]]:
        system_prompt = None
        cleaned_messages = []
        for msg in messages:
            if msg["role"] == "system":
                system_prompt = msg["content"]
            else:
                cleaned_messages.append({
                    "role": msg["role"],
                    "content": msg["content"]
                })
        return system_prompt, cleaned_messages

    async def chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> str:
        if not self.api_key:
            return "Error: Anthropic API key is not configured."

        url = f"{self.base_url}/messages"
        system, user_msgs = self._extract_system_and_messages(messages)

        payload = {
            "model": model or "claude-3-5-sonnet-20240620",
            "messages": user_msgs,
            "max_tokens": max_tokens,
            "temperature": temperature
        }
        if system:
            payload["system"] = system

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, headers=self._get_headers(), json=payload, timeout=30.0)
                if res.status_code != 200:
                    logger.bind(category="errors").error(f"Anthropic non-200 code: {res.status_code} | {res.text}")
                    return f"Error: Anthropic returned code {res.status_code}."
                data = res.json()
                content = data.get("content", [])
                if content:
                    return content[0].get("text", "")
                return "Error: Empty response content from Anthropic."
            except Exception as e:
                logger.bind(category="errors").error(f"Anthropic request error: {str(e)}")
                return f"Error processing Anthropic request: {str(e)}"

    async def chat_stream(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> AsyncGenerator[str, None]:
        if not self.api_key:
            yield "Error: Anthropic API key is not configured."
            return

        url = f"{self.base_url}/messages"
        system, user_msgs = self._extract_system_and_messages(messages)

        payload = {
            "model": model or "claude-3-5-sonnet-20240620",
            "messages": user_msgs,
            "max_tokens": max_tokens,
            "temperature": temperature,
            "stream": True
        }
        if system:
            payload["system"] = system

        async with httpx.AsyncClient() as client:
            try:
                async with client.stream("POST", url, headers=self._get_headers(), json=payload, timeout=30.0) as response:
                    if response.status_code != 200:
                        yield f"Error: Anthropic stream returned code {response.status_code}."
                        return

                    async for line in response.aiter_lines():
                        if not line or not line.strip():
                            continue
                        
                        if line.startswith("data: "):
                            data_str = line[6:].strip()
                            try:
                                data_json = json.loads(data_str)
                                event_type = data_json.get("type")
                                
                                # Delta updates return text parts
                                if event_type == "content_block_delta":
                                    delta = data_json.get("delta", {})
                                    text = delta.get("text")
                                    if text:
                                        yield text
                            except Exception:
                                continue
            except Exception as e:
                logger.bind(category="errors").error(f"Anthropic stream error: {str(e)}")
                yield f"Error processing Anthropic stream: {str(e)}"

    async def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str,
        prompt: str,
        model: Optional[str] = None
    ) -> str:
        if not self.api_key:
            return "Error: Anthropic API key is not configured."

        url = f"{self.base_url}/messages"
        base64_image = base64.b64encode(image_bytes).decode("utf-8")

        # Anthropic vision content block structure:
        payload = {
            "model": model or "claude-3-5-sonnet-20240620",
            "max_tokens": 1024,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": mime_type,
                                "data": base64_image
                            }
                        },
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ]
        }

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, headers=self._get_headers(), json=payload, timeout=30.0)
                if res.status_code != 200:
                    logger.bind(category="errors").error(f"Anthropic Vision non-200: {res.status_code} | {res.text}")
                    return f"Error: Anthropic returned code {res.status_code}."
                data = res.json()
                content = data.get("content", [])
                if content:
                    return content[0].get("text", "")
                return "Error: Empty response content from Anthropic vision."
            except Exception as e:
                logger.bind(category="errors").error(f"Anthropic vision error: {str(e)}")
                return f"Error processing Anthropic vision request: {str(e)}"
