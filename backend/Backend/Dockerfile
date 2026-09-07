# Use official Python 3.13-slim image for development/production stability
FROM python:3.13-slim as base

# Set working directory inside container
WORKDIR /workspace

# Install system dependencies (build-essential needed for greenlet / pg8000)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Environment flags
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Copy dependency configs
COPY requirements.txt .

# Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy source trees
COPY . .

# Expose Uvicorn API port
EXPOSE 8000

# Run development server as default entrypoint command
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
