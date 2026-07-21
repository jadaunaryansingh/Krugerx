import json
from typing import AsyncGenerator, Dict, Any, List, Optional
import httpx
from loguru import logger

from app.core.config import settings
from app.services.ai.base import BaseAIService


class GroqService(BaseAIService):
    """
    Groq implementation utilizing OpenAI-compatible chat endpoints for high-speed inference.
    """
    def __init__(self) -> None:
        self.api_key = settings.GROQ_API_KEY
        self.base_url = "https://api.groq.com/openai/v1"

    def _get_headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key or ''}",
            "Content-Type": "application/json"
        }

    async def chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> str:
        if not self.api_key:
            return "Error: Groq API key is not configured."

        url = f"{self.base_url}/chat/completions"
        payload = {
            "model": model or "llama3-8b-8192",
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, headers=self._get_headers(), json=payload, timeout=30.0)
                if res.status_code != 200:
                    logger.bind(category="errors").error(f"Groq non-200 code: {res.status_code} | {res.text}")
                    return f"Error: Groq returned code {res.status_code}."
                data = res.json()
                return data["choices"][0]["message"]["content"]
            except Exception as e:
                logger.bind(category="errors").error(f"Groq request error: {str(e)}")
                return f"Error processing Groq request: {str(e)}"

    async def chat_stream(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> AsyncGenerator[str, None]:
        if not self.api_key:
            yield "Error: Groq API key is not configured."
            return

        url = f"{self.base_url}/chat/completions"
        payload = {
            "model": model or "llama3-8b-8192",
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": True
        }

        async with httpx.AsyncClient() as client:
            try:
                async with client.stream("POST", url, headers=self._get_headers(), json=payload, timeout=30.0) as response:
                    if response.status_code != 200:
                        yield f"Error: Groq returned code {response.status_code}."
                        return

                    async for line in response.aiter_lines():
                        if not line or not line.strip():
                            continue
                        if line.startswith("data: "):
                            data_str = line[6:].strip()
                            if data_str == "[DONE]":
                                break
                            try:
                                data_json = json.loads(data_str)
                                choices = data_json.get("choices", [])
                                if choices:
                                    delta = choices[0].get("delta", {})
                                    content = delta.get("content")
                                    if content:
                                        yield content
                            except Exception:
                                continue
            except Exception as e:
                logger.bind(category="errors").error(f"Groq stream error: {str(e)}")
                yield f"Error processing Groq stream: {str(e)}"

    async def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str,
        prompt: str,
        model: Optional[str] = None
    ) -> str:
        # Groq's standard text models don't support multi-modal image inputs. LLaMA 3.2 Vision models might,
        # but let's provide a clear fallback response showing lack of multimodal layout if vision is hit.
        return "Error: Image analysis is not supported on Groq provider currently."
