from fastapi import Request, FastAPI, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError, HTTPException
from loguru import logger


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """
    Handles HTTPExceptions and logs them under the error category.
    """
    logger.bind(category="errors").error(
        f"HTTP {exc.status_code} - {request.method} {request.url.path} - Detail: {exc.detail}"
    )
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "message": str(exc.detail),
            "data": None,
            "errors": [exc.detail]
        }
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """
    Handles Pydantic input validation errors.
    """
    errors = exc.errors()
    formatted_errors = [
        {"field": ".".join(map(str, err["loc"])), "msg": err["msg"], "type": err["type"]}
        for err in errors
    ]
    logger.bind(category="errors").warning(
        f"Validation Failure - {request.method} {request.url.path} - Errors: {formatted_errors}"
    )
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "message": "Input validation failed.",
            "data": None,
            "errors": formatted_errors
        }
    )


async def general_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Catch-all error handler for unexpected server exceptions.
    """
    logger.bind(category="errors").exception(
        f"Unhandled system error - {request.method} {request.url.path} - Error: {str(exc)}"
    )
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "message": "An unexpected internal server error occurred.",
            "data": None,
            "errors": [str(exc)]
        }
    )


def register_error_handlers(app: FastAPI) -> None:
    """
    Utility function to register exception handlers to the FastAPI app.
    """
    app.add_exception_handler(HTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, general_exception_handler)
