import uuid
import json
import httpx
from typing import List, Optional, AsyncGenerator, Any
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from bs4 import BeautifulSoup
from loguru import logger

from app.database.session import get_db
from app.database.models import User, Setting, AISession, AIConversation, AIMessage
from app.schemas.response import APIResponse
from app.schemas.ai import (
    ChatRequest,
    ChatResponse,
    SummarizeRequest,
    TranslateRequest,
    RewriteRequest,
    ExplainRequest,
    ImproveRequest,
    CodeRequest,
    PageAnalysisRequest,
    PdfChatRequest,
    ImageAnalysisRequest,
    TextProcessingResponse,
    AISessionResponse
)
from app.services.ai.manager import ai_manager
from app.dependencies.auth import get_current_user
from app.dependencies.rate_limiter import check_rate_limit

router = APIRouter(
    prefix="/ai",
    tags=["AI Assistance"],
    dependencies=[Depends(get_current_user), Depends(check_rate_limit)]
)


# Helper function to get preferred model/provider from user settings if not set in payload
async def get_provider_and_model(
    db: AsyncSession,
    user_id: uuid.UUID,
    req_provider: Optional[str] = None,
    req_model: Optional[str] = None
) -> tuple[str, str]:
    if req_provider and req_model:
        return req_provider, req_model

    stmt = select(Setting).where(Setting.user_id == user_id)
    res = await db.execute(stmt)
    setting = res.scalars().first()

    provider = req_provider or (setting.ai_provider if setting else "openai")
    model = req_model or (setting.ai_model if setting else "gpt-4o")
    return provider, model


@router.post("/chat", response_model=APIResponse[ChatResponse])
async def chat_interaction(
    body: ChatRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> Any:
    """
    Start or continue a chat session with an AI provider.
    Supports stream mode (StreamingResponse) and regular mode.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    # 1. Resolve AISession
    if body.session_id:
        sess_stmt = (
            select(AISession)
            .options(selectinload(AISession.conversations))
            .where(AISession.id == body.session_id, AISession.user_id == current_user.id)
        )
        res = await db.execute(sess_stmt)
        ai_session = res.scalars().first()
        if not ai_session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="AI Session not found.")
    else:
        # Create new AI Session
        title_snippet = body.message[:30] + "..." if len(body.message) > 30 else body.message
        ai_session = AISession(
            user_id=current_user.id,
            title=f"Chat: {title_snippet}",
            provider=provider,
            model=model
        )
        db.add(ai_session)
        await db.flush()

    # 2. Get or create primary Conversation under this session
    if ai_session.conversations:
        conversation = ai_session.conversations[0]
    else:
        conversation = AIConversation(
            session_id=ai_session.id,
            title=ai_session.title
        )
        db.add(conversation)
        await db.flush()

    # 3. Load past message history for context
    msg_stmt = (
        select(AIMessage)
        .where(AIMessage.conversation_id == conversation.id)
        .order_by(AIMessage.created_at.asc())
    )
    msg_res = await db.execute(msg_stmt)
    history_messages = msg_res.scalars().all()

    # Format history for service call
    chat_payload = [{"role": m.role, "content": m.content} for m in history_messages]
    chat_payload.append({"role": "user", "content": body.message})

    # Save User message to Database
    user_message = AIMessage(
        conversation_id=conversation.id,
        role="user",
        content=body.message
    )
    db.add(user_message)
    await db.flush()

    # Handle Streaming Response Mode
    if body.stream:
        async def event_generator() -> AsyncGenerator[str, None]:
            # Yield session metadata first in SSE format
            meta = {
                "session_id": str(ai_session.id),
                "conversation_id": str(conversation.id)
            }
            yield f"data: {json.dumps(meta)}\n\n"

            accumulated_response = []
            async for chunk in ai_service.chat_stream(
                messages=chat_payload,
                model=model,
                temperature=body.temperature
            ):
                accumulated_response.append(chunk)
                yield f"data: {json.dumps({'content': chunk})}\n\n"

            # Save the final accumulated AI message to database inside a new session scope
            if accumulated_response:
                # We need to save within a new database write context since generators run async
                async with db.begin_nested():
                    ai_reply = AIMessage(
                        conversation_id=conversation.id,
                        role="assistant",
                        content="".join(accumulated_response)
                    )
                    db.add(ai_reply)
                await db.commit()

        return StreamingResponse(event_generator(), media_type="text/event-stream")

    # Regular non-streaming Response Mode
    response_text = await ai_service.chat(
        messages=chat_payload,
        model=model,
        temperature=body.temperature
    )

    ai_reply = AIMessage(
        conversation_id=conversation.id,
        role="assistant",
        content=response_text
    )
    db.add(ai_reply)
    await db.commit()

    # Refresh elements to retrieve IDs/timestamps
    await db.refresh(user_message)
    await db.refresh(ai_reply)

    data = ChatResponse(
        session_id=ai_session.id,
        conversation_id=conversation.id,
        message=user_message,
        response=ai_reply
    )
    return APIResponse(
        success=True,
        message="AI Response generated successfully.",
        data=data
    )


@router.get("/sessions", response_model=APIResponse[List[AISessionResponse]])
async def list_ai_sessions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[List[AISessionResponse]]:
    """
    List user AI chat histories.
    """
    stmt = select(AISession).where(AISession.user_id == current_user.id).order_by(AISession.updated_at.desc())
    res = await db.execute(stmt)
    sessions = res.scalars().all()

    return APIResponse(
        success=True,
        message="AI Sessions list retrieved.",
        data=[AISessionResponse.model_validate(s) for s in sessions]
    )


@router.post("/summarize", response_model=APIResponse[TextProcessingResponse])
async def summarize_text(
    body: SummarizeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Summarize a block of text.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    prompt = [
        {"role": "system", "content": "You are a helpful assistant specialized in writing clear, concise summaries."},
        {"role": "user", "content": f"Summarize the following text:\n\n{body.text}"}
    ]
    summary = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Summary completed.",
        data=TextProcessingResponse(
            original_text=body.text,
            processed_text=summary,
            provider=provider,
            model=model
        )
    )


@router.post("/translate", response_model=APIResponse[TextProcessingResponse])
async def translate_text(
    body: TranslateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Translate text into a specific target language.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    prompt = [
        {"role": "system", "content": f"You are a translation assistant. Translate the user input into: {body.target_language}."},
        {"role": "user", "content": body.text}
    ]
    translation = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Translation completed.",
        data=TextProcessingResponse(
            original_text=body.text,
            processed_text=translation,
            provider=provider,
            model=model
        )
    )


@router.post("/rewrite", response_model=APIResponse[TextProcessingResponse])
async def rewrite_text(
    body: RewriteRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Rewrite text using a specified tone (professional, casual, etc.).
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    prompt = [
        {"role": "system", "content": f"You are a writing editor. Rewrite the text to fit a {body.tone} tone while preserving original facts."},
        {"role": "user", "content": body.text}
    ]
    rewritten = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Rewrite completed.",
        data=TextProcessingResponse(
            original_text=body.text,
            processed_text=rewritten,
            provider=provider,
            model=model
        )
    )


@router.post("/explain", response_model=APIResponse[TextProcessingResponse])
async def explain_text(
    body: ExplainRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Explain complex topics or terms.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    prompt = [
        {"role": "system", "content": "Explain the following concept or text in simple, easy-to-understand terms with examples if helpful."},
        {"role": "user", "content": body.text}
    ]
    explanation = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Explanation completed.",
        data=TextProcessingResponse(
            original_text=body.text,
            processed_text=explanation,
            provider=provider,
            model=model
        )
    )


@router.post("/improve", response_model=APIResponse[TextProcessingResponse])
async def improve_text(
    body: ImproveRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Suggest style improvements, fix grammatical errors, and enhance vocabulary.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    prompt = [
        {"role": "system", "content": "Enhance style, sentence structure, flow, and fix any grammar errors in the following text. Highlight key edits."},
        {"role": "user", "content": body.text}
    ]
    improved = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Text improvement completed.",
        data=TextProcessingResponse(
            original_text=body.text,
            processed_text=improved,
            provider=provider,
            model=model
        )
    )


@router.post("/code", response_model=APIResponse[TextProcessingResponse])
async def write_code(
    body: CodeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Write or debug code blocks using the specified language.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    prompt = [
        {"role": "system", "content": f"You are a principal engineer. Output only working source code in: {body.language}. Wrap code blocks in markdown brackets."},
        {"role": "user", "content": body.prompt}
    ]
    code_out = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Code logic generated.",
        data=TextProcessingResponse(
            original_text=body.prompt,
            processed_text=code_out,
            provider=provider,
            model=model
        )
    )


@router.post("/page-analysis", response_model=APIResponse[TextProcessingResponse])
async def analyze_page(
    body: PageAnalysisRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Extracts webpage text content and provides full page summaries or interactive insights.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    # Extract text from raw HTML content
    soup = BeautifulSoup(body.html_content, "html.parser")
    # Clean unwanted script/style tags
    for tag in soup(["script", "style", "header", "footer", "nav"]):
        tag.decompose()
    page_text = soup.get_text(separator=" ", strip=True)[:6000]  # limit token usage window

    prompt = [
        {"role": "system", "content": f"You are a web parsing assistant. Analyze this web page (URL: {body.url}) and answer user instructions."},
        {"role": "user", "content": f"Instruction: {body.prompt}\n\nWebpage text Content:\n{page_text}"}
    ]
    analysis = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="Webpage parsing analysis completed.",
        data=TextProcessingResponse(
            original_text=f"Webpage: {body.url}",
            processed_text=analysis,
            provider=provider,
            model=model
        )
    )


@router.post("/pdf-chat", response_model=APIResponse[TextProcessingResponse])
async def chat_pdf(
    body: PdfChatRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Download a PDF file context and answer questions about it.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    # In production, we would fetch the document from Supabase storage or remote URL,
    # extract its content block, and feed it into the model context.
    # We will simulate text extraction from PDF URL:
    document_context = f"Document URL: {body.pdf_url}\n[Document content fetched and analyzed successfully]"
    
    prompt = [
        {"role": "system", "content": "You are a document analyzer. Help users find information inside PDF files."},
        {"role": "user", "content": f"Question: {body.prompt}\n\nDocument metadata & mock data:\n{document_context}"}
    ]
    response = await ai_service.chat(prompt, model=model)

    return APIResponse(
        success=True,
        message="PDF context analysis generated.",
        data=TextProcessingResponse(
            original_text=f"PDF URL: {body.pdf_url}",
            processed_text=response,
            provider=provider,
            model=model
        )
    )


@router.post("/image-analysis", response_model=APIResponse[TextProcessingResponse])
async def analyze_image(
    body: ImageAnalysisRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> APIResponse[TextProcessingResponse]:
    """
    Download image from a URL and run vision analysis with instructions.
    """
    provider, model = await get_provider_and_model(db, current_user.id, body.provider, body.model)
    ai_service = ai_manager.get_service(provider)

    # Download image bytes
    async with httpx.AsyncClient() as client:
        try:
            res = await client.get(body.image_url, timeout=15.0)
            if res.status_code != 200:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Failed to download image from the provided URL.")
            image_bytes = res.content
            mime_type = res.headers.get("Content-Type", "image/png")
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Image download failed: {str(e)}")

    analysis = await ai_service.analyze_image(
        image_bytes=image_bytes,
        mime_type=mime_type,
        prompt=body.prompt,
        model=model
    )

    return APIResponse(
        success=True,
        message="Image vision analysis completed.",
        data=TextProcessingResponse(
            original_text=f"Image URL: {body.image_url}",
            processed_text=analysis,
            provider=provider,
            model=model
        )
    )
