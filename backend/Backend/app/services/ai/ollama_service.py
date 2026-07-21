import json
from typing import AsyncGenerator, Dict, Any, List, Optional
import httpx
from loguru import logger

from app.core.config import settings
from app.services.ai.base import BaseAIService


class OllamaService(BaseAIService):
    """
    Ollama service proxying chat operations to a local Ollama server deployment.
    """
    def __init__(self) -> None:
        self.base_url = settings.OLLAMA_BASE_URL.rstrip("/")

    async def chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> str:
        url = f"{self.base_url}/api/chat"
        payload = {
            "model": model or "llama3",
            "messages": messages,
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens
            },
            "stream": False
        }

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, json=payload, timeout=60.0)
                if res.status_code != 200:
                    logger.bind(category="errors").error(f"Ollama non-200 code: {res.status_code} | {res.text}")
                    return f"Error: Ollama returned status code {res.status_code}."
                data = res.json()
                return data.get("message", {}).get("content", "")
            except Exception as e:
                logger.bind(category="errors").warning(f"Ollama local connection failed: {str(e)}")
                return f"Error connecting to local Ollama instance at {self.base_url}. Make sure Ollama is running."

    async def chat_stream(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> AsyncGenerator[str, None]:
        url = f"{self.base_url}/api/chat"
        payload = {
            "model": model or "llama3",
            "messages": messages,
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens
            },
            "stream": True
        }

        async with httpx.AsyncClient() as client:
            try:
                async with client.stream("POST", url, json=payload, timeout=60.0) as response:
                    if response.status_code != 200:
                        yield f"Error: Ollama returned status code {response.status_code}."
                        return

                    async for line in response.aiter_lines():
                        if not line or not line.strip():
                            continue
                        try:
                            data_json = json.loads(line)
                            content = data_json.get("message", {}).get("content")
                            if content:
                                yield content
                        except Exception:
                            continue
            except Exception as e:
                logger.bind(category="errors").warning(f"Ollama local connection stream failed: {str(e)}")
                yield f"Error connecting to local Ollama instance: {str(e)}"

    async def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str,
        prompt: str,
        model: Optional[str] = None
    ) -> str:
        # LLava/multimodal model support on local Ollama via base64 images inside content array
        import base64
        base64_image = base64.b64encode(image_bytes).decode("utf-8")

        url = f"{self.base_url}/api/chat"
        payload = {
            "model": model or "llava",
            "messages": [
                {
                    "role": "user",
                    "content": prompt,
                    "images": [base64_image]
                }
            ],
            "stream": False
        }

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, json=payload, timeout=120.0)
                if res.status_code != 200:
                    return f"Error: Ollama returned status code {res.status_code}."
                data = res.json()
                return data.get("message", {}).get("content", "")
            except Exception as e:
                return f"Error connecting to Ollama vision models: {str(e)}"
