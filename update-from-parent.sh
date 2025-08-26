#!/bin/bash

# Update from Parent Directory Script
# Cách sử dụng: chmod +x update-from-parent.sh && ./update-from-parent.sh

echo "⚡ Update from Parent - Binh Luan Generate By Thanh MKT"
echo "🕐 Bắt đầu: $(date)"
echo "📁 Thư mục hiện tại: $(pwd)"

# Di chuyển lên thư mục cha (có .git)
echo "📂 Di chuyển lên thư mục cha..."
cd ..

# Kiểm tra Git repository
if [ ! -d ".git" ]; then
    echo "❌ Không tìm thấy Git repository"
    echo "💡 Hãy chạy trong thư mục dự án có .git"
    exit 1
fi

echo "✅ Tìm thấy Git repository"

# Backup nhanh
echo "💾 Backup nhanh..."
BACKUP_DIR="/tmp/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r Vietscriptsinhton/dist $BACKUP_DIR/ 2>/dev/null || true
cp -r Vietscriptsinhton/backend $BACKUP_DIR/ 2>/dev/null || true

# Dừng PM2 process (nếu có)
echo "⏸️ Dừng backend..."
pm2 stop binh-luan-backend 2>/dev/null || true

# Pull code mới từ GitHub
echo "📥 Pull code mới từ GitHub..."
git fetch origin
git reset --hard origin/main
echo "✅ Code đã được cập nhật"

# Vào thư mục dự án
echo "📂 Vào thư mục dự án..."
cd Vietscriptsinhton

# Cài đặt dependencies
echo "📦 Cài đặt dependencies..."
npm install

# Build frontend
echo "🔨 Build frontend..."
npm run build

# Khởi động lại PM2
echo "🚀 Khởi động lại backend..."
pm2 delete binh-luan-backend 2>/dev/null || true
pm2 start backend/server.js --name "binh-luan-backend"
pm2 save

# Kiểm tra status
echo "📊 Kiểm tra status..."
sleep 2
pm2 status

echo ""
echo "✅ Update hoàn thành! Thời gian: $(date)"
echo "💾 Backup: $BACKUP_DIR"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"

# Xóa backup cũ (sau 1 giờ)
echo "🧹 Backup sẽ tự động xóa sau 1 giờ"
( sleep 3600 && rm -rf $BACKUP_DIR ) &
