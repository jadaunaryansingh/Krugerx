from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from app.services.ai.base import BaseAIService
from app.services.ai.openai_service import OpenAIService
from app.services.ai.gemini_service import GeminiService
from app.services.ai.anthropic_service import AnthropicService
from app.services.ai.groq_service import GroqService
from app.services.ai.ollama_service import OllamaService


class AIServiceManager:
    """
    Registry manager to obtain appropriate AI service client depending on provider settings.
    """
    def __init__(self) -> None:
        self._services: Dict[str, BaseAIService] = {
            "openai": OpenAIService(),
            "gemini": GeminiService(),
            "anthropic": AnthropicService(),
            "groq": GroqService(),
            "ollama": OllamaService()
        }

    def get_service(self, provider: str) -> BaseAIService:
        """
        Returns the requested AI service implementation class.
        """
        provider_key = provider.lower().strip()
        service = self._services.get(provider_key)
        if not service:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported AI provider '{provider}'. Available choices are: {list(self._services.keys())}"
            )
        return service


# Global instance
ai_manager = AIServiceManager()
