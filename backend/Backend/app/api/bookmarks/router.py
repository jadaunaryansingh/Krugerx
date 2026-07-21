import uuid
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.responses import Response, StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
import io

from app.database.session import get_db
from app.database.models import User, Bookmark, Folder
from app.schemas.response import APIResponse
from app.schemas.bookmarks import (
    BookmarkCreate,
    BookmarkUpdate,
    BookmarkResponse,
    FolderCreate,
    FolderUpdate,
    FolderTreeResponse
)
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit
from app.utils.bookmarks import parse_netscape_html, generate_netscape_html

router = APIRouter(
    prefix="/bookmarks",
    tags=["Bookmarks"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


# --- FOLDERS ENDPOINTS ---

@router.post("/folders", response_model=APIResponse[FolderTreeResponse], status_code=status.HTTP_201_CREATED)
async def create_folder(
    body: FolderCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[FolderTreeResponse]:
    """
    Create a new bookmark folder. Supports nesting via parent_id.
    """
    if body.parent_id:
        parent_stmt = select(Folder).where(Folder.id == body.parent_id, Folder.user_id == current_user.id)
        parent_res = await db.execute(parent_stmt)
        if not parent_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Parent folder not found.")

    folder = Folder(
        user_id=current_user.id,
        name=body.name,
        parent_id=body.parent_id
    )
    db.add(folder)
    await db.commit()
    await db.refresh(folder)

    # Return empty lists for subfolders and bookmarks as it is newly created
    return APIResponse(
        success=True,
        message="Folder created successfully.",
        data=FolderTreeResponse(id=folder.id, name=folder.name, parent_id=folder.parent_id, subfolders=[], bookmarks=[])
    )


@router.get("/folders/tree", response_model=APIResponse[List[FolderTreeResponse]])
async def get_folder_tree(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[FolderTreeResponse]]:
    """
    Get nested tree layout of all folders and bookmarks for the user.
    """
    # Fetch folders with their nested relationships
    stmt = (
        select(Folder)
        .options(
            selectinload(Folder.subfolders),
            selectinload(Folder.bookmarks)
        )
        .where(Folder.user_id == current_user.id)
    )
    res = await db.execute(stmt)
    all_folders = res.scalars().all()

    # Build tree starting from root folders (where parent_id is None)
    folder_map = {f.id: f for f in all_folders}
    root_nodes = []

    # Map database folders to response schemas
    for folder in all_folders:
        if folder.parent_id is None:
            root_nodes.append(folder)

    return APIResponse(
        success=True,
        message="Bookmark tree retrieved successfully.",
        data=[FolderTreeResponse.model_validate(node) for node in root_nodes]
    )


@router.put("/folders/{folder_id}", response_model=APIResponse[FolderTreeResponse])
async def update_folder(
    folder_id: uuid.UUID,
    body: FolderUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[FolderTreeResponse]:
    """
    Update folder metadata or move folder hierarchy.
    """
    stmt = select(Folder).where(Folder.id == folder_id, Folder.user_id == current_user.id)
    res = await db.execute(stmt)
    folder = res.scalars().first()

    if not folder:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Folder not found.")

    if body.name is not None:
        folder.name = body.name

    if body.parent_id is not None:
        # Prevent self-referencing folder loop
        if body.parent_id == folder_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Folder cannot be its own parent.")
        
        # Check parent folder existence
        parent_stmt = select(Folder).where(Folder.id == body.parent_id, Folder.user_id == current_user.id)
        parent_res = await db.execute(parent_stmt)
        if not parent_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Parent folder not found.")
        
        folder.parent_id = body.parent_id

    await db.commit()
    await db.refresh(folder)

    return APIResponse(
        success=True,
        message="Folder updated successfully.",
        data=FolderTreeResponse.model_validate(folder)
    )


@router.delete("/folders/{folder_id}", response_model=APIResponse[None])
async def delete_folder(
    folder_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Delete a folder. Bookmarks and subfolders inside it are automatically deleted/updated by foreign key cascade.
    """
    stmt = select(Folder).where(Folder.id == folder_id, Folder.user_id == current_user.id)
    res = await db.execute(stmt)
    folder = res.scalars().first()

    if not folder:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Folder not found.")

    await db.delete(folder)
    await db.commit()

    return APIResponse(
        success=True,
        message="Folder and its contents deleted successfully."
    )


# --- BOOKMARKS ENDPOINTS ---

@router.post("", response_model=APIResponse[BookmarkResponse], status_code=status.HTTP_201_CREATED)
async def create_bookmark(
    body: BookmarkCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[BookmarkResponse]:
    """
    Create a new bookmark.
    """
    if body.folder_id:
        # Check folder exists
        folder_stmt = select(Folder).where(Folder.id == body.folder_id, Folder.user_id == current_user.id)
        folder_res = await db.execute(folder_stmt)
        if not folder_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target folder not found.")

    bookmark = Bookmark(
        user_id=current_user.id,
        folder_id=body.folder_id,
        title=body.title,
        url=body.url,
        position=body.position
    )
    db.add(bookmark)
    await db.commit()
    await db.refresh(bookmark)

    return APIResponse(
        success=True,
        message="Bookmark created successfully.",
        data=BookmarkResponse.model_validate(bookmark)
    )


@router.get("", response_model=APIResponse[List[BookmarkResponse]])
async def get_bookmarks(
    folder_id: Optional[uuid.UUID] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[BookmarkResponse]]:
    """
    List bookmarks, optionally filtered by folder_id.
    """
    stmt = select(Bookmark).where(Bookmark.user_id == current_user.id)
    if folder_id:
        stmt = stmt.where(Bookmark.folder_id == folder_id)
    
    res = await db.execute(stmt)
    bookmarks = res.scalars().all()

    return APIResponse(
        success=True,
        message="Bookmarks retrieved successfully.",
        data=[BookmarkResponse.model_validate(b) for b in bookmarks]
    )


@router.put("/{bookmark_id}", response_model=APIResponse[BookmarkResponse])
async def update_bookmark(
    bookmark_id: uuid.UUID,
    body: BookmarkUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[BookmarkResponse]:
    """
    Update bookmark details (title, URL, target folder, or positioning).
    """
    stmt = select(Bookmark).where(Bookmark.id == bookmark_id, Bookmark.user_id == current_user.id)
    res = await db.execute(stmt)
    bookmark = res.scalars().first()

    if not bookmark:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bookmark not found.")

    if body.title is not None:
        bookmark.title = body.title
    if body.url is not None:
        bookmark.url = body.url
    if body.position is not None:
        bookmark.position = body.position
    if body.folder_id is not None:
        # Check folder exists
        folder_stmt = select(Folder).where(Folder.id == body.folder_id, Folder.user_id == current_user.id)
        folder_res = await db.execute(folder_stmt)
        if not folder_res.scalars().first():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target folder not found.")
        bookmark.folder_id = body.folder_id

    await db.commit()
    await db.refresh(bookmark)

    return APIResponse(
        success=True,
        message="Bookmark updated successfully.",
        data=BookmarkResponse.model_validate(bookmark)
    )


@router.delete("/{bookmark_id}", response_model=APIResponse[None])
async def delete_bookmark(
    bookmark_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[None]:
    """
    Delete a bookmark.
    """
    stmt = select(Bookmark).where(Bookmark.id == bookmark_id, Bookmark.user_id == current_user.id)
    res = await db.execute(stmt)
    bookmark = res.scalars().first()

    if not bookmark:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bookmark not found.")

    await db.delete(bookmark)
    await db.commit()

    return APIResponse(
        success=True,
        message="Bookmark deleted successfully."
    )


@router.get("/search", response_model=APIResponse[List[BookmarkResponse]])
async def search_bookmarks(
    query: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[BookmarkResponse]]:
    """
    Search bookmarks by matching title or URL query substrings.
    """
    stmt = select(Bookmark).where(
        Bookmark.user_id == current_user.id,
        (Bookmark.title.ilike(f"%{query}%")) | (Bookmark.url.ilike(f"%{query}%"))
    )
    res = await db.execute(stmt)
    bookmarks = res.scalars().all()

    return APIResponse(
        success=True,
        message=f"Found {len(bookmarks)} matching bookmarks.",
        data=[BookmarkResponse.model_validate(b) for b in bookmarks]
    )


# --- IMPORT/EXPORT ENDPOINTS ---

@router.post("/import", response_model=APIResponse[Dict[str, int]])
async def import_bookmarks(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[Dict[str, int]]:
    """
    Import bookmarks uploaded as a Netscape HTML bookmarks file.
    Automatically creates required subfolder structures.
    """
    contents = await file.read()
    html_str = contents.decode("utf-8", errors="ignore")
    parsed_items = parse_netscape_html(html_str)

    # Helper function to recursively find/create folders
    async def get_or_create_folder(folder_path: List[str]) -> Optional[uuid.UUID]:
        if not folder_path:
            return None
        
        parent_id = None
        for folder_name in folder_path:
            # Check if this folder already exists under this parent
            stmt = select(Folder).where(
                Folder.user_id == current_user.id,
                Folder.name == folder_name,
                Folder.parent_id == parent_id
            )
            res = await db.execute(stmt)
            folder = res.scalars().first()
            
            if not folder:
                folder = Folder(
                    user_id=current_user.id,
                    name=folder_name,
                    parent_id=parent_id
                )
                db.add(folder)
                await db.flush() # Sync ID
            
            parent_id = folder.id
        return parent_id

    imported_count = 0
    for item in parsed_items:
        folder_id = await get_or_create_folder(item.get("folders", []))
        bookmark = Bookmark(
            user_id=current_user.id,
            folder_id=folder_id,
            title=item["title"],
            url=item["url"]
        )
        db.add(bookmark)
        imported_count += 1

    await db.commit()

    return APIResponse(
        success=True,
        message="Bookmarks imported successfully.",
        data={"count": imported_count}
    )


@router.get("/export")
async def export_bookmarks(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> StreamingResponse:
    """
    Export bookmarks in Netscape HTML format.
    """
    # Fetch flat bookmarks list along with folder names
    stmt = (
        select(Bookmark, Folder.name.label("folder_name"))
        .outerjoin(Folder, Bookmark.folder_id == Folder.id)
        .where(Bookmark.user_id == current_user.id)
    )
    res = await db.execute(stmt)
    results = res.all()

    bookmarks_list = []
    for row in results:
        bookmark, folder_name = row
        bookmarks_list.append({
            "title": bookmark.title,
            "url": bookmark.url,
            "folder_name": folder_name
        })

    html_content = generate_netscape_html(bookmarks_list)
    
    file_like = io.BytesIO(html_content.encode("utf-8"))
    
    return StreamingResponse(
        file_like,
        media_type="text/html",
        headers={
            "Content-Disposition": "attachment; filename=krugerx_bookmarks.html",
            "Cache-Control": "no-cache"
        }
    )
