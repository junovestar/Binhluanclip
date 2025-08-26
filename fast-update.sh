#!/bin/bash

# Fast Update Script - Cập nhật nhanh nhất lên VPS Ubuntu
# Cách sử dụng: chmod +x fast-update.sh && ./fast-update.sh

echo "⚡ Fast Update - Binh Luan Generate By Thanh MKT"
echo "🕐 Bắt đầu: $(date)"

# Kiểm tra thư mục dự án
PROJECT_DIR="/var/www/binh-luan-generate"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Thư mục dự án không tồn tại: $PROJECT_DIR"
    echo "💡 Hãy chạy quick-deploy.sh trước"
    exit 1
fi

# Backup nhanh (chỉ backup thư mục dist và backend)
echo "💾 Backup nhanh..."
BACKUP_DIR="/tmp/binh-luan-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r $PROJECT_DIR/dist $BACKUP_DIR/ 2>/dev/null || true
cp -r $PROJECT_DIR/backend $BACKUP_DIR/ 2>/dev/null || true

# Dừng PM2 process
echo "⏸️ Dừng backend..."
pm2 stop binh-luan-backend 2>/dev/null || true

# Chuyển đến thư mục dự án
cd $PROJECT_DIR

# Pull code mới từ Git (nếu sử dụng Git)
if [ -d ".git" ]; then
    echo "📥 Pull code mới..."
    git fetch origin
    git reset --hard origin/main
    echo "✅ Code đã được cập nhật"
else
    echo "⚠️ Không tìm thấy Git repository"
    echo "💡 Hãy upload files mới thủ công vào $PROJECT_DIR"
fi

# Cài đặt dependencies mới (chỉ nếu có package.json mới)
if [ -f "package.json" ]; then
    echo "📦 Cài đặt dependencies..."
    npm install --production
fi

# Build frontend
echo "🔨 Build frontend..."
npm run build

# Khởi động lại PM2
echo "🚀 Khởi động lại backend..."
pm2 delete binh-luan-backend 2>/dev/null || true
pm2 start backend/server.js --name "binh-luan-backend" --cwd $PROJECT_DIR
pm2 save

# Restart Nginx (nhanh)
echo "🔄 Restart Nginx..."
sudo systemctl reload nginx

# Kiểm tra status
echo "📊 Kiểm tra status..."
sleep 2
pm2 status

echo ""
echo "✅ Update hoàn thành! Thời gian: $(date)"
echo "🌐 Truy cập: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-vps-ip')"
echo "💾 Backup: $BACKUP_DIR"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"

# Xóa backup cũ (sau 1 giờ)
echo "🧹 Backup sẽ tự động xóa sau 1 giờ"
( sleep 3600 && rm -rf $BACKUP_DIR ) &
