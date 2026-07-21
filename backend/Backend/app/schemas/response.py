from typing import Generic, TypeVar, Optional, List, Any
from pydantic import BaseModel

T = TypeVar('T')


class APIResponse(BaseModel, Generic[T]):
    """
    Standard envelope for all API responses.
    """
    success: bool
    message: str
    data: Optional[T] = None
    errors: Optional[List[Any]] = None
