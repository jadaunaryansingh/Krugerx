@echo off
title KrugerX Launcher
echo ╔══════════════════════════════════════╗
echo ║        KrugerX — Starting Up         ║
echo ╚══════════════════════════════════════╝
echo.

:: Start backend
echo [1/2] Starting backend on port 8000...
start "KrugerX Backend" /MIN cmd /c "cd /d C:\Users\ks759\Krugerx\backend\Backend && python -m uvicorn main:app --host 127.0.0.1 --port 8000"

:: Wait for backend to initialize
echo       Waiting for backend...
timeout /t 3 /nobreak >nul

:: Launch the browser
echo [2/2] Launching KrugerX Browser...
start "" "C:\Users\ks759\Krugerx\frontend\build\windows\x64\runner\Release\krugerx.exe"

echo.
echo ✓ KrugerX is running!
echo   Backend: http://127.0.0.1:8000
echo   Close this window to stop the backend.
echo.
pause
