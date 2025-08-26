@echo off
title Binh Luan Generate By Thanh MKT
color 0A

echo.
echo ========================================
echo   Binh Luan Generate By Thanh MKT
echo      AI YouTube Comment Generator
echo ========================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js chua duoc cai dat!
    echo.
    echo Vui long tai va cai dat Node.js tu:
    echo https://nodejs.org
    echo.
    echo Sau khi cai dat xong, chay lai file nay.
    echo.
    pause
    exit /b 1
)

echo [INFO] Node.js version:
node --version
echo.

REM Auto install if needed
if not exist "node_modules" (
    echo [INFO] Lan dau chay - dang cai dat dependencies...
    echo Qua trinh nay mat khoang 2-3 phut...
    echo.
    npm install
    if errorlevel 1 (
        echo.
        echo [ERROR] Loi cai dat! Cac giai phap:
        echo 1. Kiem tra ket noi internet
        echo 2. Chay Command Prompt voi quyen Administrator
        echo 3. Xoa thu muc node_modules va chay lai
        echo.
        pause
        exit /b 1
    )
    echo.
    echo [SUCCESS] Cai dat thanh cong!
    echo.
)

echo [INFO] Dang khoi dong ung dung...
echo.
echo  ^> Frontend: http://localhost:5173
echo  ^> Backend:  http://localhost:3004
echo.
echo  Huong dan su dung:
echo  1. Trinh duyet se tu dong mo
echo  2. Click bieu tuong cai dat (gear) de nhap API Key
echo  3. Nhap link YouTube va bat dau xu ly
echo.
echo  Nhan Ctrl+C de dung ung dung
echo.

REM Wait 2 seconds then open browser
timeout /t 2 /nobreak >nul
start "" "http://localhost:5173"

REM Start the application
npm run dev

REM If npm run dev exits, show message
echo.
echo [INFO] Ung dung da dung.
echo Nhan phim bat ky de dong cua so...
pause
