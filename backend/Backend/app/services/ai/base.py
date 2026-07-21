from abc import ABC, abstractmethod
from typing import AsyncGenerator, Dict, Any, List, Optional


class BaseAIService(ABC):
    """
    Abstract Base Class defining standard operations for AI providers.
    """
    @abstractmethod
    async def chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> str:
        """
        Sends chat conversation payload to the AI provider and returns response text.
        """
        pass

    @abstractmethod
    async def chat_stream(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024
    ) -> AsyncGenerator[str, None]:
        """
        Sends chat conversation payload to the AI provider and yields tokens as they arrive.
        """
        pass

    @abstractmethod
    async def analyze_image(
        self,
        image_bytes: bytes,
        mime_type: str,
        prompt: str,
        model: Optional[str] = None
    ) -> str:
        """
        Sends vision prompt alongside raw image bytes to the AI provider.
        """
        pass
