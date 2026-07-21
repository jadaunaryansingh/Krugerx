import uuid
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field


class ChatMessageSchema(BaseModel):
    role: str = Field(..., description="system, user, assistant")
    content: str


class ChatRequest(BaseModel):
    session_id: Optional[uuid.UUID] = None
    message: str
    provider: Optional[str] = None
    model: Optional[str] = None
    temperature: float = 0.7
    stream: bool = False


class SummarizeRequest(BaseModel):
    text: str
    provider: Optional[str] = None
    model: Optional[str] = None


class TranslateRequest(BaseModel):
    text: str
    target_language: str
    provider: Optional[str] = None
    model: Optional[str] = None


class RewriteRequest(BaseModel):
    text: str
    tone: str = Field("professional", description="professional, casual, funny, academic, concise")
    provider: Optional[str] = None
    model: Optional[str] = None


class ExplainRequest(BaseModel):
    text: str
    provider: Optional[str] = None
    model: Optional[str] = None


class ImproveRequest(BaseModel):
    text: str
    provider: Optional[str] = None
    model: Optional[str] = None


class CodeRequest(BaseModel):
    prompt: str
    language: Optional[str] = Field("python", description="python, javascript, c++, sql, HTML, CSS")
    provider: Optional[str] = None
    model: Optional[str] = None


class PageAnalysisRequest(BaseModel):
    url: str
    html_content: str
    prompt: Optional[str] = Field("Analyze this webpage content and summarize key takeaways.", description="Vision or summary query")
    provider: Optional[str] = None
    model: Optional[str] = None


class PdfChatRequest(BaseModel):
    pdf_url: str
    prompt: str
    provider: Optional[str] = None
    model: Optional[str] = None


class ImageAnalysisRequest(BaseModel):
    image_url: str
    prompt: str = Field("Describe this image in detail.", description="Question about the image")
    provider: Optional[str] = None
    model: Optional[str] = None


# --- RESPONSES ---

class AISessionResponse(BaseModel):
    id: uuid.UUID
    title: str
    provider: str
    model: str

    class Config:
        from_attributes = True


class AIMessageResponse(BaseModel):
    id: uuid.UUID
    role: str
    content: str
    created_at: Any

    class Config:
        from_attributes = True


class ChatResponse(BaseModel):
    session_id: uuid.UUID
    conversation_id: uuid.UUID
    message: AIMessageResponse
    response: AIMessageResponse


class TextProcessingResponse(BaseModel):
    original_text: str
    processed_text: str
    provider: str
    model: str
