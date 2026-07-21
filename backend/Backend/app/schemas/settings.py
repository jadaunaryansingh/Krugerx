from typing import Optional
from pydantic import BaseModel, Field, HttpUrl


class SettingResponse(BaseModel):
    theme: str = Field("system", description="UI Theme preference: light, dark, system")
    search_engine: str = Field("google", description="Default search engine: google, bing, duckduckgo, brave")
    homepage_url: str = Field("https://google.com")
    language: str = Field("en")
    font_size: int = Field(14, ge=8, le=36)
    privacy_tracking_protection: bool = Field(True)
    ai_provider: str = Field("openai")
    ai_model: str = Field("gpt-4o")

    class Config:
        from_attributes = True


class SettingUpdate(BaseModel):
    theme: Optional[str] = None
    search_engine: Optional[str] = None
    homepage_url: Optional[str] = None
    language: Optional[str] = None
    font_size: Optional[int] = Field(None, ge=8, le=36)
    privacy_tracking_protection: Optional[bool] = None
    ai_provider: Optional[str] = None
    ai_model: Optional[str] = None
