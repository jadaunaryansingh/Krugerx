import json
import base64
from typing import AsyncGenerator, Dict, Any, List, Optional
import httpx
from loguru import logger

from app.core.config import settings
from app.services.ai.base import BaseAIService


class GeminiService(BaseAIService):
    """
    Gemini implementation utilizing direct HTTP endpoints for generateContent and streams.
    """
    def __init__(self) -> None:
        self.api_key = settings.GEMINI_API_KEY
        self.base_url = "https://generativelanguage.googleapis.com/v1beta"

    def _prepare_payload(self, messages: List[Dict[str, str]], temperature: float, max_tokens: int) -> Dict[str, Any]:
        contents = []
        system_instruction = None

        for msg in messages:
            role = msg["role"]
            content = msg["content"]
            
            if role == "system":
                system_instruction = {"parts": [{"text": content}]}
            elif role == "assistant":
                contents.append({"role": "model", "parts": [{"text": content}]})
            else:  # user
                contents.append({"role": "user", "parts": [{"text": content}]})

        payload: Dict[str, Any] = {
            "contents": contents,
            "generationConfig": {
                "temperature": temperature,
                "maxOutputTokens": max_tokens
            }
        }
        if system_instruction:
            payload["systemInstruction"] = system_instruction

        return payload

    async def chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> str:
        if not self.api_key:
            return "Error: Gemini API key is not configured."

        selected_model = model or "gemini-1.5-flash"
        url = f"{self.base_url}/models/{selected_model}:generateContent?key={self.api_key}"
        payload = self._prepare_payload(messages, temperature, max_tokens)

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, json=payload, timeout=30.0)
                if res.status_code != 200:
                    logger.bind(category="errors").error(f"Gemini non-200 code: {res.status_code} | {res.text}")
                    return f"Error: Gemini returned code {res.status_code}."
                
                data = res.json()
                # Extract text path
                candidates = data.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if parts:
                        return parts[0].get("text", "")
                return "Error: Empty response content from Gemini."
            except Exception as e:
                logger.bind(category="errors").error(f"Gemini request error: {str(e)}")
                return f"Error processing Gemini request: {str(e)}"

    async def chat_stream(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> AsyncGenerator[str, None]:
        if not self.api_key:
            yield "Error: Gemini API key is not configured."
            return

        selected_model = model or "gemini-1.5-flash"
        # SSE stream version of the Gemini endpoint is: serverSentEvents=true or streamGenerateContent
        url = f"{self.base_url}/models/{selected_model}:streamGenerateContent?key={self.api_key}"
        payload = self._prepare_payload(messages, temperature, max_tokens)

        async with httpx.AsyncClient() as client:
            try:
                async with client.stream("POST", url, json=payload, timeout=30.0) as response:
                    if response.status_code != 200:
                        yield f"Error: Gemini stream returned code {response.status_code}."
                        return

                    # Gemini returns stream as a JSON array of parts, or lines in Server-Sent Events if requested.
                    # Since it returns a JSON stream, we can read chunks/lines, or read it stream-parsed.
                    # Standard API returns stream as text blocks:
                    # [
                    #   { "candidates": ... },
                    #   { "candidates": ... }
                    # ]
                    # Let's accumulate buffer chunks and find JSON matches.
                    buffer = ""
                    async for chunk in response.aiter_text():
                        buffer += chunk
                        # Clean up brackets for incremental parse or handle standard line reads
                        # The standard Gemini stream endpoint wraps the list: [\n  {...},\n  {...}\n]
                        # Let's clean the separators and find isolated objects:
                        while True:
                            buffer = buffer.strip()
                            if buffer.startswith("["):
                                buffer = buffer[1:].strip()
                            if buffer.startswith(","):
                                buffer = buffer[1:].strip()
                            
                            if not buffer:
                                break
                            
                            # Extract single JSON object by counting matching curly braces
                            brace_count = 0
                            end_index = -1
                            in_string = False
                            escape = False
                            
                            for i, char in enumerate(buffer):
                                if char == '"' and not escape:
                                    in_string = not in_string
                                elif char == '\\' and in_string:
                                    escape = not escape
                                    continue
                                
                                if not in_string:
                                    if char == '{':
                                        brace_count += 1
                                    elif char == '}':
                                        brace_count -= 1
                                        if brace_count == 0:
                                            end_index = i
                                            break
                                escape = False

                            if end_index != -1:
                                obj_str = buffer[:end_index + 1]
                                buffer = buffer[end_index + 1:].strip()
                                try:
                                    data = json.loads(obj_str)
                                    candidates = data.get("candidates", [])
                                    if candidates:
                                        parts = candidates[0].get("content", {}).get("parts", [])
                                        if parts:
                                            text = parts[0].get("text", "")
                                            if text:
                                                yield text
                                except Exception:
                                    pass
                            else:
                                break
            except Exception as e:
                logger.bind(category="errors").error(f"Gemini stream error: {str(e)}")
                yield f"Error processing Gemini stream: {str(e)}"

    async def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str,
        prompt: str,
        model: Optional[str] = None
    ) -> str:
        if not self.api_key:
            return "Error: Gemini API key is not configured."

        selected_model = model or "gemini-1.5-flash"
        url = f"{self.base_url}/models/{selected_model}:generateContent?key={self.api_key}"

        base64_image = base64.b64encode(image_bytes).decode("utf-8")

        # Gemini inlineData structure:
        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt},
                        {
                            "inlineData": {
                                "mimeType": mime_type,
                                "data": base64_image
                            }
                        }
                    ]
                }
            ]
        }

        async with httpx.AsyncClient() as client:
            try:
                res = await client.post(url, json=payload, timeout=30.0)
                if res.status_code != 200:
                    logger.bind(category="errors").error(f"Gemini Vision non-200: {res.status_code} | {res.text}")
                    return f"Error: Gemini returned code {res.status_code}."
                data = res.json()
                candidates = data.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if parts:
                        return parts[0].get("text", "")
                return "Error: Empty response content from Gemini vision."
            except Exception as e:
                logger.bind(category="errors").error(f"Gemini vision error: {str(e)}")
                return f"Error processing Gemini vision request: {str(e)}"
