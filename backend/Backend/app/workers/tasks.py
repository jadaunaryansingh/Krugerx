import asyncio
import datetime
from typing import Dict, Any, List
from celery.utils.log import get_task_logger
from sqlalchemy import delete, select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.workers.celery_app import celery_app
from app.database.session import AsyncSessionLocal
from app.database.models import History, SyncQueue, User, Notification, Setting
from app.services.ai.manager import ai_manager

logger = get_task_logger(__name__)


def run_async(coro):
    """
    Helper function to run asynchronous coroutines inside synchronous Celery worker contexts.
    """
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)


@celery_app.task(name="app.workers.tasks.prune_old_history")
def prune_old_history() -> str:
    """
    Prunes browsing history older than 30 days to free database size.
    """
    async def _prune():
        cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=30)
        async with AsyncSessionLocal() as db:
            stmt = delete(History).where(History.visit_time < cutoff)
            res = await db.execute(stmt)
            await db.commit()
            return f"Pruned {res.rowcount} historical visit records."

    logger.info("Starting historical prune task...")
    result = run_async(_prune())
    logger.info(result)
    return result


@celery_app.task(name="app.workers.tasks.cleanup_sync_queue")
def cleanup_sync_queue() -> str:
    """
    Purges sync events that have been dispatched/synced and are older than 7 days.
    """
    async def _cleanup():
        cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=7)
        async with AsyncSessionLocal() as db:
            stmt = delete(SyncQueue).where(SyncQueue.synced_at < cutoff)
            res = await db.execute(stmt)
            await db.commit()
            return f"Purged {res.rowcount} synchronized queue events."

    logger.info("Starting sync queue cleanup...")
    result = run_async(_cleanup())
    logger.info(result)
    return result


@celery_app.task(name="app.workers.tasks.aggregate_analytics")
def aggregate_analytics() -> str:
    """
    Simulates high-level usage statistics aggregation.
    """
    async def _agg():
        # Quick health scan of total users
        async with AsyncSessionLocal() as db:
            res = await db.execute(select(func.count(User.id)))
            count = res.scalar() or 0
            return f"Aggregated daily analytics database counts. Active users: {count}"

    logger.info("Executing daily telemetry scan...")
    result = run_async(_agg())
    logger.info(result)
    return result


@celery_app.task(name="app.workers.tasks.process_ai_background")
def process_ai_background(user_id_str: str, message: str) -> str:
    """
    Background worker task to process complex AI tasks without blocking the main web request loop.
    For example, summarizing large background pages or processing indexing queries.
    """
    async def _process():
        import uuid
        user_uuid = uuid.UUID(user_id_str)
        
        async with AsyncSessionLocal() as db:
            # Fetch user default provider setting
            stmt = select(Setting).where(Setting.user_id == user_uuid)
            res = await db.execute(stmt)
            setting = res.scalars().first()
            provider = setting.ai_provider if setting else "openai"
            model = setting.ai_model if setting else "gpt-4o"

        # Obtain AI Service and process
        ai_service = ai_manager.get_service(provider)
        prompt = [
            {"role": "system", "content": "You are a background AI processor. Formulate insights on the text context provided."},
            {"role": "user", "content": message}
        ]
        
        response_text = await ai_service.chat(prompt, model=model)
        
        # Save results to a user notification
        async with AsyncSessionLocal() as db:
            notification = Notification(
                user_id=user_uuid,
                title="AI Background Insights ready",
                message=response_text[:500] + "..." if len(response_text) > 500 else response_text,
                type="alert",
                is_read=False
            )
            db.add(notification)
            await db.commit()

        return f"Processed background AI request. Response text saved as notification: {response_text[:50]}"

    logger.info(f"Received background AI task for user {user_id_str}.")
    result = run_async(_process())
    logger.info(result)
    return result


@celery_app.task(name="app.workers.tasks.send_push_notification")
def send_push_notification(user_id_str: str, title: str, message: str) -> str:
    """
    Pushes browser notifications and maps alert events.
    """
    async def _notify():
        import uuid
        user_uuid = uuid.UUID(user_id_str)
        async with AsyncSessionLocal() as db:
            notif = Notification(
                user_id=user_uuid,
                title=title,
                message=message,
                type="system",
                is_read=False
            )
            db.add(notif)
            await db.commit()
            return f"Push alert saved for user {user_uuid}."

    logger.info("Executing push notifier...")
    result = run_async(_notify())
    logger.info(result)
    return result
