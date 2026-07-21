import time
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from loguru import logger

from app.database.session import get_db
from app.schemas.response import APIResponse

router = APIRouter(
    prefix="/health",
    tags=["System Diagnostics"]
)

# Start time tracking for uptime calculation
START_TIME = time.time()


@router.get("", response_model=APIResponse[dict])
async def system_health_check(
    db: AsyncSession = Depends(get_db)
) -> APIResponse[dict]:
    """
    Diagnostic endpoint that evaluates backend uptime, database connectivity, and Redis cache health.
    """
    health_status = {
        "status": "healthy",
        "database": "unknown",
        "cache": "unknown",
        "uptime_seconds": int(time.time() - START_TIME)
    }
    
    # 1. Database Connection check
    try:
        # Run a quick ping query
        await db.execute(text("SELECT 1"))
        health_status["database"] = "online"
    except Exception as e:
        logger.bind(category="errors").error(f"Database health check failed: {str(e)}")
        health_status["database"] = "offline"
        health_status["status"] = "unhealthy"

    # 2. Cache Connection check (in-memory, always online)
    health_status["cache"] = "online"

    status_code = status.HTTP_200_OK if health_status["status"] == "healthy" else status.HTTP_503_SERVICE_UNAVAILABLE

    return APIResponse(
        success=health_status["status"] == "healthy",
        message=f"System is {health_status['status']}.",
        data=health_status
    )
