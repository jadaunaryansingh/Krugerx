from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger
import time

from app.core.config import settings
from app.core.logger import setup_logging
from app.middleware.error_handlers import register_error_handlers
from app.middleware.logging import LoggingAndTrackingMiddleware

# 1. Routers
from app.api.auth.router import router as auth_router
from app.api.bookmarks.router import router as bookmarks_router
from app.api.history.router import router as history_router
from app.api.settings.router import router as settings_router
from app.api.tabs.router import router as tabs_router

from app.api.search.router import router as search_router
from app.api.ai.router import router as ai_router
from app.api.sync.router import router as sync_router
from app.api.files.router import router as files_router
from app.api.analytics.router import router as analytics_router
from app.api.health.router import router as health_router
from app.api.browser.router import router as browser_router
from app.websocket.router import router as ws_router



@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Uvicorn lifespan hook to initialize logging and resource pools on startup,
    and release connection hooks on shutdown.
    """
    # Startup actions
    setup_logging()
    logger.info("Initializing Krugerx Browser Backend application service...")
    
    yield

    # Shutdown actions
    logger.info("Shutting down backend pools...")


# Initialize application instance
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Production-grade secure backend services for Krugerx AI desktop browser.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# 2. CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual desktop origins e.g. chrome-extension://...
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Custom request tracking & logging middleware
app.add_middleware(LoggingAndTrackingMiddleware)

# 4. Error handlers registration
register_error_handlers(app)

# 5. Route mounts
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(bookmarks_router, prefix=settings.API_V1_STR)
app.include_router(history_router, prefix=settings.API_V1_STR)
app.include_router(settings_router, prefix=settings.API_V1_STR)
app.include_router(tabs_router, prefix=settings.API_V1_STR)

app.include_router(search_router, prefix=settings.API_V1_STR)
app.include_router(ai_router, prefix=settings.API_V1_STR)
app.include_router(sync_router, prefix=settings.API_V1_STR)
app.include_router(files_router, prefix=settings.API_V1_STR)
app.include_router(analytics_router, prefix=settings.API_V1_STR)
app.include_router(health_router, prefix=settings.API_V1_STR)
app.include_router(ws_router, prefix=settings.API_V1_STR)
app.include_router(browser_router, prefix=settings.API_V1_STR)




@app.get("/", tags=["General"])
async def root_index():
    """
    Service landing confirmation API.
    """
    return {
        "success": True,
        "message": f"Welcome to the {settings.PROJECT_NAME} API. Access interactive documentation at /docs",
        "data": {
            "version": "1.0.0",
            "environment": settings.ENV
        }
    }
