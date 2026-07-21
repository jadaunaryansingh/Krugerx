from celery import Celery
from celery.schedules import crontab
from app.core.config import settings

# Initialize Celery app instance
celery_app = Celery(
    "krishna_workers",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

# Celery Configurations
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutes maximum runtime
)

# Register Beat Schedules
celery_app.conf.beat_schedule = {
    # Run history pruning every day at midnight UTC
    "prune-old-history-daily": {
        "task": "app.workers.tasks.prune_old_history",
        "schedule": crontab(hour=0, minute=0),
    },
    # Run sync queue maintenance hourly
    "clean-sync-queue-hourly": {
        "task": "app.workers.tasks.cleanup_sync_queue",
        "schedule": crontab(minute=0),
    },
    # Run analytics processing hourly
    "aggregate-analytics-hourly": {
        "task": "app.workers.tasks.aggregate_analytics",
        "schedule": crontab(minute=30),
    }
}

# Auto-discover tasks from app.workers package
celery_app.autodiscover_tasks(["app.workers"])
