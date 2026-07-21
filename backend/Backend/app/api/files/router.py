import os
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from app.schemas.response import APIResponse
from app.schemas.files import FileUploadResponse, SignedUrlRequest, SignedUrlResponse, FileRenameRequest
from app.services.storage.storage_service import storage_service
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit
from app.database.models import User

router = APIRouter(
    prefix="/files",
    tags=["File Storage"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


@router.post("/upload", response_model=APIResponse[FileUploadResponse], status_code=status.HTTP_201_CREATED)
async def upload_file_to_cloud(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
) -> APIResponse[FileUploadResponse]:
    """
    Upload an attachment or profile avatar to the Supabase Storage Bucket.
    Namespaces the upload destination path under user directory structures.
    """
    file_bytes = await file.read()
    filename = file.filename or "unnamed_file"
    
    # Sanitize file name
    safe_filename = "".join([c for c in filename if c.isalnum() or c in "._-"])
    destination_path = f"users/{current_user.id}/files/{safe_filename}"
    content_type = file.content_type or "application/octet-stream"

    # Call upload service
    await storage_service.upload_file(
        file_path=destination_path,
        file_bytes=file_bytes,
        content_type=content_type
    )

    # Generate a signed URL for immediate retrieval/caching
    signed_url = await storage_service.create_signed_url(destination_path, expires_in=3600)

    data = FileUploadResponse(
        file_path=destination_path,
        filename=safe_filename,
        content_type=content_type,
        url=signed_url
    )
    return APIResponse(
        success=True,
        message="File uploaded successfully.",
        data=data
    )


@router.post("/sign-url", response_model=APIResponse[SignedUrlResponse])
async def get_presigned_url(
    body: SignedUrlRequest,
    current_user: User = Depends(get_current_user)
) -> APIResponse[SignedUrlResponse]:
    """
    Generate a pre-signed retrieval link for private user documents.
    """
    # Enforce security context: make sure the requested file path belongs to the logged-in user
    expected_prefix = f"users/{current_user.id}/"
    if not body.file_path.lstrip("/").startswith(expected_prefix):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. You do not own this path resource."
        )

    signed_url = await storage_service.create_signed_url(
        file_path=body.file_path,
        expires_in=body.expires_in
    )

    data = SignedUrlResponse(
        file_path=body.file_path,
        signed_url=signed_url,
        expires_in=body.expires_in
    )
    return APIResponse(
        success=True,
        message="Pre-signed download link generated.",
        data=data
    )


@router.delete("", response_model=APIResponse[None])
async def delete_user_file(
    file_path: str,
    current_user: User = Depends(get_current_user)
) -> APIResponse[None]:
    """
    Permanently delete an uploaded resource from Supabase Storage.
    """
    # Enforce security ownership check
    expected_prefix = f"users/{current_user.id}/"
    if not file_path.lstrip("/").startswith(expected_prefix):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. You do not own this path resource."
        )

    await storage_service.delete_file(file_path)

    return APIResponse(
        success=True,
        message="Resource deleted from storage."
    )


@router.post("/rename", response_model=APIResponse[None])
async def rename_user_file(
    body: FileRenameRequest,
    current_user: User = Depends(get_current_user)
) -> APIResponse[None]:
    """
    Rename or move an object within the storage bucket.
    """
    expected_prefix = f"users/{current_user.id}/"
    
    # Ownership checks on source and target paths
    if (not body.old_path.lstrip("/").startswith(expected_prefix) or 
        not body.new_path.lstrip("/").startswith(expected_prefix)):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Source and target paths must belong to your directory structures."
        )

    await storage_service.rename_file(old_path=body.old_path, new_path=body.new_path)

    return APIResponse(
        success=True,
        message="File renamed successfully."
    )
