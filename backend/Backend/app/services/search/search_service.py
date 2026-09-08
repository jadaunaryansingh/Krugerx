import httpx
import time
from typing import List, Dict, Any, Optional
from bs4 import BeautifulSoup
from urllib.parse import urlparse, parse_qs, quote
from loguru import logger
import xml.etree.ElementTree as ET

from app.core.config import settings
from app.schemas.search import SearchResultItem, KnowledgePanel

# In-memory cache for SearXNG results: key -> (payload, expire_at)
# ponytail: single-process only; upgrade to shared Redis if multi-worker
_searxng_cache: Dict[str, tuple] = {}
_SEARXNG_TTL = 300  # 5 minutes
_SEARXNG_RATE: Dict[str, list] = {}  # per-user timestamps for 30 req/min limit


class SearchService:
    """
    Unified Search service that interfaces with Google, Bing, Brave, and DuckDuckGo.
    """
    def __init__(self) -> None:
        self.headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
            )
        }

    async def search(self, provider: str, query: str, user_id: Optional[str] = None) -> dict:
        """
        Execute search across configured search engine provider.
        Returns a dict containing 'results' and optionally 'knowledge_panel'.
        """
        provider = provider.lower()
        results = []
        if provider == "google":
            results = await self._search_google(query)
        elif provider == "bing":
            results = await self._search_bing(query)
        elif provider == "brave":
            results = await self._search_brave(query)
        elif provider == "duckduckgo" or provider == "ddg":
            results = await self._search_duckduckgo(query)
        elif provider == "searxng":
            results = await self._search_searxng(query, user_id=user_id)
        else:
            logger.warning(f"Unknown search provider: {provider}, falling back to DuckDuckGo.")
            results = await self._search_duckduckgo(query)

        knowledge_panel = await self._fetch_knowledge_panel(query)
        
        return {
            "results": results,
            "knowledge_panel": knowledge_panel
        }

    async def _search_searxng(self, query: str, user_id: Optional[str] = None) -> List[SearchResultItem]:
        """
        Proxies search to the self-hosted SearXNG instance.
        Applies per-user rate limiting (30 req/min) and 5-minute result caching.
        """
        if not settings.SEARXNG_URL:
            logger.warning("SEARXNG_URL not configured, falling back to DuckDuckGo.")
            return await self._search_duckduckgo(query)

        # Per-user rate limit: 30 req/min
        if user_id:
            now = time.time()
            timestamps = _SEARXNG_RATE.get(user_id, [])
            timestamps = [t for t in timestamps if now - t < 60]
            if len(timestamps) >= 30:
                from fastapi import HTTPException, status
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="SearXNG rate limit exceeded. Max 30 requests/minute per user."
                )
            timestamps.append(now)
            _SEARXNG_RATE[user_id] = timestamps
            if not timestamps:  # All entries expired during cleanup
                del _SEARXNG_RATE[user_id]

        # Cache check
        cache_key = f"search:{provider.lower()}:{query.lower()}"
        cached = _searxng_cache.get(cache_key)
        if cached:
            payload, expire_at = cached
            if time.time() < expire_at:
                logger.debug(f"SearXNG cache hit: {cache_key}")
                return payload

        url = f"{settings.SEARXNG_URL.rstrip('/')}/search"
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, params={"q": query, "format": "json"}, timeout=10.0)
                res.raise_for_status()
                data = res.json()
            except httpx.TimeoutException:
                logger.bind(category="errors").error(f"SearXNG request timed out for query: {query}")
                from fastapi import HTTPException, status
                raise HTTPException(
                    status_code=status.HTTP_504_GATEWAY_TIMEOUT,
                    detail="SearXNG search engine timed out."
                )
            except httpx.HTTPStatusError as exc:
                logger.bind(category="errors").error(f"SearXNG returned HTTP {exc.response.status_code}")
                from fastapi import HTTPException, status
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail=f"SearXNG returned an error: {exc.response.status_code}"
                )
            except Exception as exc:
                logger.bind(category="errors").error(f"SearXNG unreachable: {str(exc)}")
                from fastapi import HTTPException, status
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="SearXNG search engine is unreachable."
                )

        results = [
            SearchResultItem(
                title=item.get("title", ""),
                url=item.get("url", ""),
                snippet=item.get("content", ""),
                favicon=f"https://icons.duckduckgo.com/ip3/{urlparse(item.get('url', '')).netloc}.ico"
            )
            for item in data.get("results", [])
        ]

        _searxng_cache[cache_key] = (results, time.time() + _SEARXNG_TTL)
        return results

    async def _fetch_knowledge_panel(self, query: str) -> Optional[KnowledgePanel]:
        """
        Queries Wikipedia API to fetch a brief summary and image for entities.
        """
        url = f"https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|pageimages&exintro=1&explaintext=1&piprop=original&titles={quote(query)}&redirects=1"
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, headers=self.headers, timeout=5.0)
                if res.status_code == 200:
                    data = res.json()
                    pages = data.get("query", {}).get("pages", {})
                    for page_id, page_data in pages.items():
                        if page_id == "-1":
                            continue
                        
                        title = page_data.get("title", "")
                        extract = page_data.get("extract", "")
                        if not extract or "may refer to:" in extract:
                            continue
                            
                        # Limit extract length for the panel
                        if len(extract) > 400:
                            extract = extract[:397] + "..."
                            
                        image_url = None
                        original = page_data.get("original")
                        if original:
                            image_url = original.get("source")
                            
                        page_url = f"https://en.wikipedia.org/wiki/{quote(title.replace(' ', '_'))}"
                        
                        return KnowledgePanel(
                            title=title,
                            description=extract,
                            image_url=image_url,
                            url=page_url,
                            attributes={"Source": "Wikipedia"}
                        )
            except Exception as e:
                logger.bind(category="errors").error(f"Knowledge panel fetch failed: {str(e)}")
                
        return None

    async def _search_google(self, query: str) -> List[SearchResultItem]:
        """
        Queries Google Custom Search JSON API.
        """
        if not settings.GOOGLE_SEARCH_API_KEY or not settings.GOOGLE_SEARCH_CX_ID:
            logger.warning("Google search credentials missing, falling back to DuckDuckGo scraper.")
            return await self._search_duckduckgo(query)

        url = f"https://www.googleapis.com/customsearch/v1?q={quote(query)}&key={settings.GOOGLE_SEARCH_API_KEY}&cx={settings.GOOGLE_SEARCH_CX_ID}"
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url)
                if res.status_code == 200:
                    data = res.json()
                    items = data.get("items", [])
                    results = []
                    for item in items:
                        results.append(SearchResultItem(
                            title=item.get("title", ""),
                            url=item.get("link", ""),
                            snippet=item.get("snippet", ""),
                            favicon=f"https://icons.duckduckgo.com/ip3/{urlparse(item.get('link')).netloc}.ico"
                        ))
                    return results
            except Exception as e:
                logger.bind(category="errors").error(f"Google search api failed: {str(e)}")

        return await self._search_duckduckgo(query)

    async def _search_bing(self, query: str) -> List[SearchResultItem]:
        """
        Queries Bing Web Search API.
        """
        if not settings.BING_SEARCH_API_KEY:
            logger.warning("Bing search API Key missing, falling back to DuckDuckGo scraper.")
            return await self._search_duckduckgo(query)

        url = f"https://api.bing.microsoft.com/v7.0/search?q={quote(query)}"
        headers = {"Ocp-Apim-Subscription-Key": settings.BING_SEARCH_API_KEY}
        
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, headers=headers)
                if res.status_code == 200:
                    data = res.json()
                    web_pages = data.get("webPages", {}).get("value", [])
                    results = []
                    for page in web_pages:
                        results.append(SearchResultItem(
                            title=page.get("name", ""),
                            url=page.get("url", ""),
                            snippet=page.get("snippet", ""),
                            favicon=f"https://icons.duckduckgo.com/ip3/{urlparse(page.get('url')).netloc}.ico"
                        ))
                    return results
            except Exception as e:
                logger.bind(category="errors").error(f"Bing Search API failed: {str(e)}")
        
        return await self._search_duckduckgo(query)

    async def _search_brave(self, query: str) -> List[SearchResultItem]:
        """
        Queries Brave Search API.
        """
        if not settings.BRAVE_SEARCH_API_KEY:
            logger.warning("Brave search API Key missing, falling back to DuckDuckGo scraper.")
            return await self._search_duckduckgo(query)

        url = f"https://api.search.brave.com/res/v1/web/search?q={quote(query)}"
        headers = {"X-Subscription-Token": settings.BRAVE_SEARCH_API_KEY}

        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, headers=headers)
                if res.status_code == 200:
                    data = res.json()
                    results = []
                    for page in data.get("web", {}).get("results", []):
                        results.append(SearchResultItem(
                            title=page.get("title", ""),
                            url=page.get("url", ""),
                            snippet=page.get("description", ""),
                            favicon=f"https://icons.duckduckgo.com/ip3/{urlparse(page.get('url')).netloc}.ico"
                        ))
                    return results
            except Exception as e:
                logger.bind(category="errors").error(f"Brave Search API failed: {str(e)}")
        
        return await self._search_duckduckgo(query)

    async def _search_duckduckgo(self, query: str) -> List[SearchResultItem]:
        """
        Fallback DuckDuckGo scraper that parses the public HTML search interface.
        """
        url = f"https://html.duckduckgo.com/html/?q={quote(query)}"
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, headers=self.headers, timeout=10.0)
                if res.status_code != 200:
                    logger.warning(f"DuckDuckGo scraper returned status: {res.status_code}")
                    return []
                
                soup = BeautifulSoup(res.text, "html.parser")
                results = []

                # Find result card elements
                for div in soup.find_all("div", class_="result"):
                    a_title = div.find("a", class_="result__a")
                    a_snippet = div.find("a", class_="result__snippet")
                    
                    if a_title:
                        title = a_title.get_text(strip=True)
                        raw_url = a_title.get("href", "")
                        
                        # Clean DuckDuckGo redirect wrappers if present
                        actual_url = raw_url
                        if "uddg=" in raw_url:
                            parsed_url = urlparse(raw_url)
                            query_params = parse_qs(parsed_url.query)
                            if "uddg" in query_params:
                                actual_url = query_params["uddg"][0]

                        snippet = a_snippet.get_text(strip=True) if a_snippet else ""
                        favicon = f"https://icons.duckduckgo.com/ip3/{urlparse(actual_url).netloc}.ico" if actual_url else None
                        
                        results.append(SearchResultItem(
                            title=title,
                            url=actual_url,
                            snippet=snippet,
                            favicon=favicon
                        ))
                return results
            except Exception as e:
                logger.bind(category="errors").error(f"DuckDuckGo search scraper failed: {str(e)}")
                return []

    async def get_suggestions(self, query: str) -> List[str]:
        """
        Fetches Google Auto-complete queries for input suggestions.
        """
        url = f"https://suggestqueries.google.com/complete/search?client=chrome&q={quote(query)}"
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, headers=self.headers)
                if res.status_code == 200:
                    data = res.json()
                    # Response format: [query, [sugg1, sugg2, ...], [type1, type2, ...]]
                    if len(data) > 1 and isinstance(data[1], list):
                        return data[1]
            except Exception as e:
                logger.bind(category="errors").error(f"Failed to fetch auto-complete suggestions: {str(e)}")
        return []

    async def get_trending_searches(self) -> List[str]:
        """
        Fetches real-time popular daily trending search queries from Google Trends RSS.
        """
        url = "https://trends.google.com/trends/trendingsearches/daily/rss?geo=US"
        async with httpx.AsyncClient() as client:
            try:
                res = await client.get(url, headers=self.headers)
                if res.status_code == 200:
                    # Parse RSS XML
                    root = ET.fromstring(res.content)
                    trends = []
                    # In Google trends XML, each trend is a <title> child of an <item> node.
                    for item in root.findall(".//item"):
                        title_node = item.find("title")
                        if title_node is not None and title_node.text:
                            trends.append(title_node.text)
                    return trends[:10]
            except Exception as e:
                logger.bind(category="errors").error(f"Failed to load trending RSS searches: {str(e)}")
        
        # Fallbacks in case RSS parsing fails or Google returns error
        return [
            "AI browser technologies", "FastAPI web services", "Supabase authentication",
            "SQLAlchemy async drivers", "Celery task scheduler", "Websocket notification channels"
        ]


search_service = SearchService()
