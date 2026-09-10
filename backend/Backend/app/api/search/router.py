from fastapi import APIRouter, Depends, Query, status
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database.session import get_db
from app.database.models import User, SearchHistory, Setting
from app.schemas.response import APIResponse
from app.schemas.search import SearchResponse, SearchSuggestionResponse, TrendingSearchResponse
from app.services.search.search_service import search_service
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/search",
    tags=["Search"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


@router.get("", response_model=APIResponse[SearchResponse])
async def search_query(
    q: str = Query(..., min_length=1),
    provider: Optional[str] = Query(None, description="Search engine: google, bing, brave, duckduckgo"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[SearchResponse]:
    """
    Search queries across various search engine providers and return a normalized response format.
    Saves queries to the database search history for history suggestion support.
    """
    # If no provider is passed, get user default setting
    if not provider:
        stmt = select(Setting).where(Setting.user_id == current_user.id)
        res = await db.execute(stmt)
        setting = res.scalars().first()
        provider = (setting.search_engine or "duckduckgo") if setting else "duckduckgo"

    # If still duckduckgo but SearXNG is configured, prefer it (DDG HTML scraper is unreliable)
    from app.core.config import settings as _settings
    if provider == "duckduckgo" and _settings.SEARXNG_URL:
        provider = "searxng"


    # Execute search
    search_data = await search_service.search(provider=provider, query=q, user_id=str(current_user.id))
    results = search_data.get("results", [])
    knowledge_panel = search_data.get("knowledge_panel")

    # Save to history query list
    history_item = SearchHistory(
        user_id=current_user.id,
        query=q,
        engine=provider
    )
    db.add(history_item)
    await db.commit()

    return APIResponse(
        success=True,
        message="Search queries executed successfully.",
        data=SearchResponse(
            provider=provider,
            query=q,
            results=results,
            knowledge_panel=knowledge_panel
        )
    )


@router.get("/suggestions", response_model=APIResponse[SearchSuggestionResponse])
async def get_search_suggestions(
    q: str = Query(..., min_length=1),
    current_user: User = Depends(get_current_user)
) -> APIResponse[SearchSuggestionResponse]:
    """
    Fetches dynamic search query typing auto-completes.
    """
    suggestions = await search_service.get_suggestions(query=q)
    return APIResponse(
        success=True,
        message="Suggestions loaded.",
        data=SearchSuggestionResponse(
            query=q,
            suggestions=suggestions
        )
    )


@router.get("/trending", response_model=APIResponse[TrendingSearchResponse])
async def get_trends(
    current_user: User = Depends(get_current_user)
) -> APIResponse[TrendingSearchResponse]:
    """
    Fetches current web trending searches and popular queries.
    """
    trends = await search_service.get_trending_searches()
    return APIResponse(
        success=True,
        message="Trending searches loaded.",
        data=TrendingSearchResponse(trends=trends)
    )
