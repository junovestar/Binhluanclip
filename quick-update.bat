@echo off
chcp 65001 >nul
echo ⚡ Quick Update - Binh Luan Generate By Thanh MKT
echo.

REM Cấu hình VPS
set VPS_IP=your-vps-ip
set VPS_USER=root

REM Kiểm tra tham số
if not "%1"=="" set VPS_IP=%1
if not "%2"=="" set VPS_USER=%2

echo 🎯 Target: %VPS_USER%@%VPS_IP%
echo.

REM Kiểm tra Git
echo 📥 Kiểm tra Git repository...
if not exist ".git" (
    echo ❌ Không tìm thấy Git repository
    echo 💡 Hãy commit và push code trước khi update
    pause
    exit /b 1
)

REM Commit và push code mới
echo 📤 Commit và push code mới...
git add .
git commit -m "Auto update $(date /t) $(time /t)"
git push origin main

REM Upload lên VPS
echo 📤 Upload lên VPS...
if exist "upload-to-vps.sh" (
    bash upload-to-vps.sh %VPS_IP% %VPS_USER%
) else (
    echo ❌ Không tìm thấy upload-to-vps.sh
    echo 💡 Hãy chạy script này trên Linux/WSL
)

echo.
echo ✅ Update hoàn thành!
echo 🌐 Truy cập: http://%VPS_IP%
pause
