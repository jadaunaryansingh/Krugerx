from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from app.core.config import settings

# Create async engine
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    future=True,
    pool_pre_ping=False,   # Don't ping on checkout — DB may be unreachable
    pool_recycle=300,
    connect_args={
        "timeout": 8,                         # asyncpg connect timeout (seconds)
        "server_settings": {
            "statement_timeout": "8000",       # ms — queries abort fast if DB is slow
        },
    },
)

# Async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI Dependency to get asynchronous database session.
    Guarantees rollback in case of uncaught exceptions and session closing.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            try:
                await session.rollback()
            except Exception:
                pass  # Session may already be in a bad state; ignore secondary error
            raise
        finally:
            await session.close()
