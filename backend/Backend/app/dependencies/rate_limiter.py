import time
from fastapi import Request, HTTPException, status
from loguru import logger
from app.core.config import settings

# Simple in-memory storage for rate limiting: client_identifier -> list of timestamps
in_memory_cache = {}


async def check_rate_limit(request: Request) -> None:
    """
    Dependency that enforces rate limits in-memory without requiring Redis.
    If the limit is exceeded, raises HTTP 429.
    Tracks requests by user_id if logged in, or client IP otherwise.
    """
    client_identifier = None
    user = getattr(request.state, "user", None)
    if user:
        client_identifier = f"user:{user.id}"
    else:
        client_identifier = f"ip:{request.client.host}" if request.client else "ip:unknown"

    limit = settings.RATE_LIMIT_PER_MINUTE
    now = time.time()

    # Get timestamps for client
    timestamps = in_memory_cache.get(client_identifier, [])

    # Filter out timestamps older than 60 seconds
    timestamps = [t for t in timestamps if now - t < 60]

    if len(timestamps) >= limit:
        logger.bind(category="security").warning(
            f"Rate limit hit! Client: {client_identifier} | Limit: {limit}/min"
        )
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many requests. Please slow down."
        )

    # Append current timestamp and save back to cache
    timestamps.append(now)
    in_memory_cache[client_identifier] = timestamps
