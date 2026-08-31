import pytest
import uuid
import jwt
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.dialects.postgresql import JSONB

@compiles(JSONB, 'sqlite')
def compile_jsonb_sqlite(type_, compiler, **kw):
    return "TEXT"

import pytest_asyncio

from app.database.models import Base, User, Bookmark
from app.dependencies.auth import get_current_user
from app.core.config import settings

@pytest_asyncio.fixture
async def sqlite_session():
    # Use in-memory SQLite for real database operations test
    from sqlalchemy.pool import StaticPool
    from sqlalchemy import event
    engine = create_async_engine(
        "sqlite+aiosqlite:///:memory:",
        poolclass=StaticPool,
        connect_args={'check_same_thread': False}
    )
    
    @event.listens_for(engine.sync_engine, "connect")
    def set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()
        
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    SessionLocal = sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)
    async with SessionLocal() as session:
        yield session
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.mark.asyncio
async def test_uuid_reconciliation(sqlite_session: AsyncSession):
    # 1. Setup a "password user" with an existing dependent row
    old_uuid = uuid.uuid4()
    email = "test@krugerx-browser.local"
    
    user = User(id=old_uuid, email=email, is_active=True)
    sqlite_session.add(user)
    await sqlite_session.flush()
    
    bookmark = Bookmark(
        id=uuid.uuid4(),
        user_id=old_uuid,
        title="Test Bookmark",
        url="https://example.com"
    )
    sqlite_session.add(bookmark)
    await sqlite_session.commit()
    
    # 2. Simulate Google JIT flow with a new UUID but same email
    new_uuid = uuid.uuid4()
    token_payload = {
        "sub": str(new_uuid),
        "email": email,
        "iss": "https://supabase.com", # Mocking Supabase issuer
        "aud": "authenticated"
    }
    
    # We need to mock verify_supabase_token because it expects a real token string
    import app.dependencies.auth
    original_verify = app.dependencies.auth.verify_supabase_token
    app.dependencies.auth.verify_supabase_token = lambda t: token_payload
    
    try:
        credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="mocked_token")
        
        # This should trigger the fallback UUID reconciliation logic
        current_user = await get_current_user(credentials=credentials, db=sqlite_session)
        
        # 3. Assertions
        assert current_user.id == new_uuid
        assert current_user.email == email
        
        # Verify the old user was deleted
        from sqlalchemy import select
        old_user = (await sqlite_session.execute(select(User).where(User.id == old_uuid))).scalars().first()
        assert old_user is None
        
        # Refresh the bookmark to bypass expire_on_commit=False caching
        await sqlite_session.refresh(bookmark)
        assert bookmark.user_id == new_uuid
        
    finally:
        # Restore mock
        app.dependencies.auth.verify_supabase_token = original_verify


@pytest.mark.asyncio
async def test_issuer_algorithm_rejection():
    # Test 1: Malformed token
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials="not_a_jwt")
    with pytest.raises(HTTPException) as excinfo:
        await get_current_user(credentials=credentials, db=None)
    assert excinfo.value.status_code == 401

    # Test 2: Wrong secret / invalid signature
    wrong_secret_token = jwt.encode(
        {"sub": str(uuid.uuid4()), "iss": settings.SUPABASE_URL, "aud": "authenticated"},
        "wrong_secret",
        algorithm="HS256"
    )
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=wrong_secret_token)
    with pytest.raises(HTTPException) as excinfo:
        await get_current_user(credentials=credentials, db=None)
    assert excinfo.value.status_code == 401
    assert "Invalid or expired authentication token" in str(excinfo.value.detail)

    # Test 3: Unexpected issuer
    wrong_issuer_token = jwt.encode(
        {"sub": str(uuid.uuid4()), "iss": "https://wrong-issuer.com", "aud": "authenticated"},
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=wrong_issuer_token)
    with pytest.raises(HTTPException) as excinfo:
        await get_current_user(credentials=credentials, db=None)
    assert excinfo.value.status_code == 401
    assert "Invalid or expired authentication token" in str(excinfo.value.detail)


@pytest.mark.asyncio
async def test_valid_token_accepted(sqlite_session: AsyncSession):
    # Test 4: Valid Supabase-signed token is accepted
    user_uuid = uuid.uuid4()
    email = "testvalid@krugerx-browser.local"
    valid_token = jwt.encode(
        {
            "sub": str(user_uuid),
            "email": email,
            "iss": settings.SUPABASE_URL,
            "aud": "authenticated"
        },
        settings.SUPABASE_JWT_SECRET,
        algorithm="HS256"
    )
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=valid_token)
    
    # Should create a new user via JIT
    current_user = await get_current_user(credentials=credentials, db=sqlite_session)
    assert current_user.id == user_uuid
    assert current_user.email == email

