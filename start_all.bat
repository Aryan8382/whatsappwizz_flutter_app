@echo off
title WhatsApp Wiz - Full Stack Launcher
cls
echo ========================================================
echo        WHATSAPP WIZ - FULL STACK LAUNCHER
echo ========================================================
echo.
echo [1/3] Launching NestJS Backend Server (Port 4000)...
start "WhatsApp Wiz Backend" cmd /k "cd /d %~dp0backend && npm run start:dev"

timeout /t 3 /nobreak >nul

echo [2/3] Launching Ngrok Tunnel (penalize-opt-reflex.ngrok-free.dev)...
start "WhatsApp Wiz Ngrok" cmd /k "ngrok http --url=penalize-opt-reflex.ngrok-free.dev 4000"

timeout /t 2 /nobreak >nul

echo [3/3] Launching Flutter App on Chrome (Port 3000)...
start "WhatsApp Wiz Flutter Chrome" cmd /k "cd /d %~dp0 && flutter run -d chrome --web-port=3000"

echo.
echo [✓] All 3 services launched in separate windows!
echo     - Backend:      http://localhost:4000/api/v1
echo     - Swagger Docs: http://localhost:4000/api/docs
echo     - Ngrok Public: https://penalize-opt-reflex.ngrok-free.dev
echo     - Flutter Web:  http://localhost:3000
echo.
pause
