from typing import List, Optional
from pydantic import BaseModel


class SearchResultItem(BaseModel):
    title: str
    url: str
    snippet: str
    favicon: Optional[str] = None


class SearchResponse(BaseModel):
    provider: str
    query: str
    results: List[SearchResultItem]


class SearchSuggestionResponse(BaseModel):
    query: str
    suggestions: List[str]


class TrendingSearchResponse(BaseModel):
    trends: List[str]
