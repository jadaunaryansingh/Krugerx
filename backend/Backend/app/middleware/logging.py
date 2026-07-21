import uuid
import time
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from loguru import logger


class LoggingAndTrackingMiddleware(BaseHTTPMiddleware):
    """
    Middleware to inject unique request IDs, track processing latency, 
    and log request lifecycle details using Loguru.
    """
    async def dispatch(self, request: Request, call_next) -> Response:
        # 1. Request ID Generation/Propagation
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        request.state.request_id = request_id

        # 2. Timing
        start_time = time.perf_counter()
        
        # Process the request
        try:
            response = await call_next(request)
        except Exception as e:
            # Re-raise to let the general exception handler handle it, but log here too.
            process_time = time.perf_counter() - start_time
            logger.bind(category="errors").error(
                f"Exception during request {request.method} {request.url.path}: {str(e)} | Latency: {process_time:.4f}s"
            )
            raise e

        process_time = time.perf_counter() - start_time

        # 3. Add Custom Headers
        response.headers["X-Request-ID"] = request_id
        response.headers["X-Process-Time"] = f"{process_time:.4f}s"

        # 4. Extract Client Meta
        client_ip = request.client.host if request.client else "unknown"
        user_agent = request.headers.get("user-agent", "unknown")

        # 5. Log structured details
        log_message = (
            f"IP: {client_ip} | ID: {request_id} | "
            f"\"{request.method} {request.url.path}\" | "
            f"Status: {response.status_code} | Latency: {process_time:.4f}s | "
            f"UA: {user_agent}"
        )

        # Route logs based on path context
        if "/api/v1/auth" in request.url.path or "security" in request.url.path:
            logger.bind(category="security").info(f"[SECURITY] {log_message}")
        else:
            logger.bind(category="api").info(log_message)

        return response
