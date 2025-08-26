#!/bin/bash

# Reset Complete Script - Xóa và setup lại hoàn toàn
# Cách sử dụng: chmod +x reset-complete.sh && ./reset-complete.sh

echo "🔄 Reset Complete - Binh Luan Generate By Thanh MKT"
echo "🕐 Bắt đầu: $(date)"
echo "⚠️ CẢNH BÁO: Script này sẽ xóa dự án hiện tại và setup lại từ đầu!"
echo ""

# Repository URL
GIT_REPO="https://github.com/junovestar/Vietscriptsinhton.git"
echo "📥 Repository: $GIT_REPO"

echo "📥 Repository: $GIT_REPO"
echo ""

# Xác nhận
read -p "❓ Bạn có chắc chắn muốn xóa và setup lại? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ Hủy bỏ!"
    exit 1
fi

echo ""
echo "🚀 Bắt đầu reset..."

# 1. Backup dự án hiện tại
echo "=== 1. BACKUP DỰ ÁN HIỆN TẠI ==="
BACKUP_DIR="~/sinhton-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "~/sinhton" ]; then
    cp -r ~/sinhton $BACKUP_DIR
    echo "✅ Đã backup vào: $BACKUP_DIR"
else
    echo "⚠️ Không tìm thấy dự án để backup"
fi

# 2. Dừng tất cả services
echo "=== 2. DỪNG SERVICES ==="
echo "⏸️ Dừng PM2..."
pm2 stop binh-luan-backend 2>/dev/null || true
pm2 delete binh-luan-backend 2>/dev/null || true

echo "⏸️ Dừng Nginx..."
sudo systemctl stop nginx 2>/dev/null || true

# 3. Xóa dự án cũ
echo "=== 3. XÓA DỰ ÁN CŨ ==="
echo "🗑️ Xóa thư mục dự án..."
rm -rf ~/sinhton 2>/dev/null || true

echo "🗑️ Xóa thư mục Nginx..."
sudo rm -rf /var/www/binh-luan-generate 2>/dev/null || true

# 4. Clone lại từ GitHub
echo "=== 4. CLONE LẠI TỪ GITHUB ==="
echo "📥 Clone repository..."
cd ~
git clone $GIT_REPO sinhton

if [ ! -d "sinhton" ]; then
    echo "❌ Clone thất bại!"
    exit 1
fi

echo "✅ Clone thành công"

# 5. Vào thư mục dự án
echo "=== 5. SETUP DỰ ÁN ==="
cd sinhton

# Tìm thư mục dự án (có thể nested)
if [ -d "Vietscriptsinhton" ]; then
    cd Vietscriptsinhton
    if [ -d "Vietscriptsinhton" ]; then
        cd Vietscriptsinhton
    fi
fi

echo "📁 Thư mục hiện tại: $(pwd)"

# 6. Cài đặt dependencies
echo "📦 Cài đặt dependencies..."
npm install

# 7. Build frontend
echo "🔨 Build frontend..."
npm run build

# 8. Tạo thư mục Nginx
echo "📋 Setup Nginx..."
sudo mkdir -p /var/www/binh-luan-generate
sudo cp -r dist /var/www/binh-luan-generate/
sudo chown -R www-data:www-data /var/www/binh-luan-generate/
sudo chmod -R 755 /var/www/binh-luan-generate/

# 9. Khởi động backend
echo "🚀 Khởi động backend..."
pm2 start backend/server.js --name "binh-luan-backend"
pm2 save

# 10. Khởi động Nginx
echo "🌐 Khởi động Nginx..."
sudo systemctl start nginx

# 11. Kiểm tra status
echo "=== 6. KIỂM TRA STATUS ==="
sleep 3

echo "📊 PM2 Status:"
pm2 status

echo ""
echo "🌐 Nginx Status:"
sudo systemctl status nginx --no-pager

echo ""
echo "🔍 Test connections:"
# Test backend
curl -s -o /dev/null -w "Backend: %{http_code}\n" http://localhost:3004/health 2>/dev/null || echo "❌ Backend không phản hồi"

# Test Nginx
curl -s -o /dev/null -w "Nginx: %{http_code}\n" http://localhost 2>/dev/null || echo "❌ Nginx không phản hồi"

# Test domain
DOMAIN=$(grep "server_name" /etc/nginx/sites-available/binh-luan-generate 2>/dev/null | head -1 | awk '{print $2}' | sed 's/;//')
if [ -n "$DOMAIN" ]; then
    curl -s -o /dev/null -w "Domain ($DOMAIN): %{http_code}\n" http://$DOMAIN 2>/dev/null || echo "❌ Domain không phản hồi"
fi

echo ""
echo "✅ Reset Complete hoàn thành! Thời gian: $(date)"
echo "💾 Backup: $BACKUP_DIR"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"
echo "🌐 Website: http://$DOMAIN"

# Hướng dẫn rollback
echo ""
echo "🔄 Nếu cần rollback:"
echo "pm2 stop binh-luan-backend"
echo "sudo systemctl stop nginx"
echo "rm -rf ~/sinhton"
echo "mv $BACKUP_DIR ~/sinhton"
echo "cd ~/sinhton && pm2 start backend/server.js --name 'binh-luan-backend'"
echo "sudo systemctl start nginx"
