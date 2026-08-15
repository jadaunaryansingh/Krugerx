from typing import List, Optional
from pydantic import BaseModel


class SearchResultItem(BaseModel):
    title: str
    url: str
    snippet: str
    favicon: Optional[str] = None


class KnowledgePanel(BaseModel):
    title: str
    description: str
    image_url: Optional[str] = None
    url: Optional[str] = None
    attributes: Optional[dict] = None

class SearchResponse(BaseModel):
    provider: str
    query: str
    results: List[SearchResultItem]
    knowledge_panel: Optional[KnowledgePanel] = None


class SearchSuggestionResponse(BaseModel):
    query: str
    suggestions: List[str]


class TrendingSearchResponse(BaseModel):
    trends: List[str]
