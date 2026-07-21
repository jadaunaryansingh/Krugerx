import os
import sys
from loguru import logger

def setup_logging() -> None:
    """
    Configures Loguru logging. Removes default handlers and registers sinks 
    for stdout and rotating log files segregated by log category (api, security, worker, errors).
    """
    # Ensure logs directory exists
    os.makedirs("logs", exist_ok=True)

    # Clear default logger configuration
    logger.remove()

    # Formats
    log_format = (
        "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
        "<level>{level: <8}</level> | "
        "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
        "<level>{message}</level>"
    )

    # 1. Console Standard Output Handler (Includes everything)
    logger.add(
        sys.stdout,
        format=log_format,
        level="INFO",
        enqueue=True
    )

    # 2. API logs
    logger.add(
        "logs/api.log",
        filter=lambda record: record["extra"].get("category") == "api",
        format="{time:YYYY-MM-DD HH:mm:ss.SSS} | {level} | {message}",
        level="INFO",
        rotation="10 MB",
        retention="10 days",
        enqueue=True
    )

    # 3. Security logs
    logger.add(
        "logs/security.log",
        filter=lambda record: record["extra"].get("category") == "security",
        format="{time:YYYY-MM-DD HH:mm:ss.SSS} | {level} | {message}",
        level="INFO",
        rotation="10 MB",
        retention="30 days",
        enqueue=True
    )

    # 4. Worker logs
    logger.add(
        "logs/workers.log",
        filter=lambda record: record["extra"].get("category") == "worker",
        format="{time:YYYY-MM-DD HH:mm:ss.SSS} | {level} | {message}",
        level="INFO",
        rotation="10 MB",
        retention="10 days",
        enqueue=True
    )

    # 5. Error logs (logs all ERRORS and CRITICALs across the system)
    logger.add(
        "logs/errors.log",
        filter=lambda record: record["level"].no >= 40,  # ERROR = 40, CRITICAL = 50
        format=log_format,
        level="ERROR",
        rotation="10 MB",
        retention="30 days",
        enqueue=True
    )
