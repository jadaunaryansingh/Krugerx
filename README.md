# KrugerX Ecosystem

> **KrugerX** is a modern, AI-powered cross-platform browser ecosystem featuring a multi-platform client app, an asynchronous FastAPI backend service, and a web distribution portal.

---

## 🌟 Architecture Overview

```
KrugerX Project Root
├── krugerx/              # Flutter Cross-Platform Client Application (Android, iOS, Windows, macOS, Linux, Web)
└── backend/
    ├── Backend/          # Production FastAPI Service (Supabase PostgreSQL, Redis, Celery, Multi-Provider AI Engine)
    └── Landingpage/      # Flask Web Application for Product Landing & Package Downloads
```

---

## 🚀 Components & Core Features

### 1. `krugerx/` — Cross-Platform Client
* **Framework**: Flutter 3.x / Dart
* **Platforms**: Android, iOS, Windows, macOS, Linux, Web
* **Features**:
  * AI-powered search & browser workspace integration
  * Cross-device synchronization for bookmarks and history
  * Customizable user settings, privacy preferences, and account management

### 2. `backend/Backend/` — High-Performance API & Background Services
* **Framework**: FastAPI (Python 3.13+) with Uvicorn
* **Database**: PostgreSQL (Supabase) via **SQLAlchemy 2.0 Async** & `asyncpg`
* **Auth & Security**: Supabase Auth & JWT Middleware validation
* **Caching & Queue**: **Redis** with **Celery** workers and **Celery Beat** periodic schedulers
* **AI Integration**: Unified connector interface for **OpenAI**, **Google Gemini**, **Anthropic Claude**, **Groq**, and **Ollama** (Local LLM)
* **Monitoring**: Integrated health check diagnostics endpoint (`/api/v1/health`)
* **Documentation**: Interactive OpenAPI / Swagger UI (`/docs`) and ReDoc (`/redoc`)

### 3. `backend/Landingpage/` — Web Portal & Downloads
* **Framework**: Flask
* **Features**: Product showcase, static downloads manager for Windows installer (`.exe`), Android package (`.apk`), and iOS bundle (`.ipa`)

---

## ⚙️ Environment Setup & Configuration

### Backend Environment (`backend/Backend/.env`)

Copy `.env.example` to `.env` in `backend/Backend/` and configure the following variables:

```ini
# Core Settings
PROJECT_NAME="Krugerx Browser Backend"
ENV=development
DEBUG=true

# Database (Supabase Async PostgreSQL)
DATABASE_URL=postgresql+asyncpg://postgres:[PASSWORD]@[HOST]:5432/postgres

# Supabase Authentication
SUPABASE_URL=https://[YOUR-PROJECT].supabase.co
SUPABASE_KEY=[YOUR-ANON-KEY]
SUPABASE_JWT_SECRET=[YOUR-JWT-SECRET]

# Redis & Celery
REDIS_URL=redis://localhost:6379/0
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0

# AI Provider API Keys
OPENAI_API_KEY=your-openai-key
GEMINI_API_KEY=your-gemini-key
ANTHROPIC_API_KEY=your-anthropic-key
GROQ_API_KEY=your-groq-key
OLLAMA_BASE_URL=http://localhost:11434
```

---

## 🛠️ Quick Start Guide

### Running Backend with Docker Compose (Recommended)

To launch the complete backend ecosystem (FastAPI, Redis, Celery Worker, and Celery Beat):

```bash
cd backend/Backend
docker-compose up --build
```
* **API Service**: `http://localhost:8000`
* **Interactive API Docs**: `http://localhost:8000/docs`

---

### Running Backend Locally (Python Virtual Environment)

1. Navigate to the backend directory:
   ```bash
   cd backend/Backend
   ```
2. Create and activate a Python virtual environment:
   ```bash
   python -m venv venv
   # On Windows:
   venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Start the FastAPI server:
   ```bash
   uvicorn main:app --reload --port 8000
   ```
5. Start Celery worker (in a separate terminal):
   ```bash
   celery -A app.workers.tasks.celery_app worker --loglevel=info
   ```

---

### Running Flutter Client App

1. Ensure Flutter SDK is installed and configured (`flutter doctor`).
2. Navigate to the `krugerx` directory:
   ```bash
   cd krugerx
   ```
3. Install Dart dependencies:
   ```bash
   flutter pub get
   ```
4. Run application:
   ```bash
   flutter run
   ```

---

### Running Landing Page Server

1. Navigate to the `backend/Landingpage` directory:
   ```bash
   cd backend/Landingpage
   ```
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Launch Flask development server:
   ```bash
   python app.py
   ```

---

## 🧪 Testing

To execute automated unit and integration tests for the backend API:

```bash
cd backend/Backend
pytest -v
```

---

## 📜 License

Internal / Proprietary Software — All rights reserved.
