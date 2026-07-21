# Krugerx Browser Backend

Production-ready backend for the AI-powered desktop **Krugerx Browser**, built with FastAPI, Supabase, SQLAlchemy 2.0 Async, Celery, and Redis.

---

## Technical Architecture

The architecture enforces decoupling between layers to maintain high testability and clean execution:
1. **API Endpoints** (`app/api/`): Validates input, parses payloads, and maps HTTP requests using FastAPI routers.
2. **Business Services** (`app/services/`): Decoupled orchestration layers managing file operations, query normalization, multi-provider AI connectors, and sync logic.
3. **Database Entities** (`app/database/`): Asynchronous session initialization and SQLAlchemy 2.0 declarative database modeling mapping 20+ tables.
4. **Middlewares** (`app/middleware/`): Intercepts HTTP request contexts injecting UUID tracking IDs, measuring execution latency, and routing security auditing.
5. **Background Task Queue** (`app/workers/`): Asynchronous process workers processing history cleanups, AI insights generation, and push notification triggers via Redis.

---

## Tech Stack & Dependencies

- **Python 3.13+**
- **FastAPI** & **Uvicorn**
- **Pydantic V2** (Data schemas & settings validation)
- **SQLAlchemy 2.0 Async** & **asyncpg** (PostgreSQL async engine)
- **Redis** (CORS management, caching, rate limiting, and task brokerage)
- **Celery** & **Celery Beat** (Periodic scheduler queues)
- **Supabase Auth & Storage API** (Direct REST client endpoints for security)
- **Loguru** (Segregated log routers)
- **Pytest** (Asyncio fixtures and mock client test suites)

---

## Configuration & Environment Setup

Copy the template configuration file:
```bash
cp .env.example .env
```

Ensure the database URL has the async prefix `postgresql+asyncpg://`:
```ini
# Environment settings
PROJECT_NAME="Krugerx Browser Backend"
ENV=development
DEBUG=true

# Database (Supabase PostgreSQL)
DATABASE_URL=postgresql+asyncpg://postgres:[YOUR-PASSWORD]@db.your-project.supabase.co:5432/postgres

# Supabase Keys
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
SUPABASE_JWT_SECRET=your-supabase-jwt-secret

# Caching and Task Queue
REDIS_URL=redis://localhost:6379/0
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0

# AI Provider Keys
OPENAI_API_KEY=your-openai-key
GEMINI_API_KEY=your-gemini-key
ANTHROPIC_API_KEY=your-anthropic-key
GROQ_API_KEY=your-groq-key
OLLAMA_BASE_URL=http://localhost:11434
```

---

## Run Locally

### 1. Pre-requisites
Make sure you have **Docker** and **Docker Compose** installed, or Python 3.13+ and a local **Redis** instance.

### 2. Local Python Environment
Create virtual environment and install dependencies:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

Start the local web API:
```bash
uvicorn main:app --reload --port 8000
```

Start Celery asynchronous task workers:
```bash
celery -A app.workers.tasks.celery_app worker --loglevel=info
```

Start Celery Beat periodic task scheduler:
```bash
celery -A app.workers.tasks.celery_app beat --loglevel=info
```

---

## Docker Deployment (Compose)

Launch the entire ecosystem (FastAPI, Redis, Celery workers, and Beat schedulers) with a single command:
```bash
docker-compose up --build
```
This binds:
- The FastAPI application web server to `http://localhost:8000`
- The Redis server instance to port `6379`
- Logs automatically written to the local `./logs/` directory

---

## Verification & Interactive Docs

- **Swagger UI**: Visit `http://localhost:8000/docs` to test every endpoint.
- **ReDoc**: Alternative documentation interface at `http://localhost:8000/redoc`.
- **System Health Diagnostics**: Query `http://localhost:8000/api/v1/health` for DB connectivity metrics.

### Run Testing Suite
Run automated unit tests validating Auth synchronization, Bookmark CRUD, folders, and Settings routing:
```bash
pytest -v
```
All database operations and API auth states are mocked to execute instantly.
