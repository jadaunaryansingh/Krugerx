import uuid
from typing import Optional
from pydantic import BaseModel, EmailStr, Field


class UserSignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6, description="Password must be at least 6 characters")
    display_name: Optional[str] = Field(None, max_length=100)


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenRefreshRequest(BaseModel):
    refresh_token: str = Field(..., description="Supabase refresh token")


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user_id: uuid.UUID


class ProfileResponse(BaseModel):
    id: uuid.UUID
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None

    class Config:
        from_attributes = True


class UserMeResponse(BaseModel):
    id: uuid.UUID
    email: str
    is_active: bool
    profile: Optional[ProfileResponse] = None

    class Config:
        from_attributes = True
