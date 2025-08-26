#!/bin/bash

# Clean All Script - Xóa hết và làm lại từ đầu
# Cách sử dụng: chmod +x clean-all.sh && ./clean-all.sh

echo "🧹 Clean All - Binh Luan Generate By Thanh MKT"
echo "🕐 Bắt đầu: $(date)"
echo "⚠️ CẢNH BÁO: Script này sẽ xóa hết và làm lại từ đầu!"
echo ""

# Xác nhận
read -p "❓ Bạn có chắc chắn muốn xóa hết và làm lại? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ Hủy bỏ!"
    exit 1
fi

echo ""
echo "🚀 Bắt đầu clean all..."

# 1. Dừng tất cả services
echo "=== 1. DỪNG SERVICES ==="
echo "⏸️ Dừng PM2..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

echo "⏸️ Dừng Nginx..."
sudo systemctl stop nginx 2>/dev/null || true

# 2. Xóa tất cả dự án và cấu hình
echo "=== 2. XÓA TẤT CẢ ==="
echo "🗑️ Xóa dự án..."
rm -rf ~/sinhton 2>/dev/null || true

echo "🗑️ Xóa thư mục Nginx..."
sudo rm -rf /var/www/binh-luan-generate 2>/dev/null || true

echo "🗑️ Xóa tất cả sites enabled..."
sudo rm -f /etc/nginx/sites-enabled/* 2>/dev/null || true

echo "🗑️ Xóa cấu hình Nginx..."
sudo rm -f /etc/nginx/sites-available/binh-luan-generate 2>/dev/null || true

echo "🗑️ Xóa cache Nginx..."
sudo rm -rf /var/cache/nginx/* 2>/dev/null || true

echo "🗑️ Xóa logs Nginx..."
sudo rm -f /var/log/nginx/access.log 2>/dev/null || true
sudo rm -f /var/log/nginx/error.log 2>/dev/null || true

# 3. Kiểm tra đã xóa hết
echo "=== 3. KIỂM TRA ĐÃ XÓA ==="
echo "📁 Thư mục home:"
ls -la ~/ | grep sinhton || echo "✅ Không còn thư mục sinhton"

echo ""
echo "📁 Nginx sites enabled:"
sudo ls -la /etc/nginx/sites-enabled/ || echo "✅ Không còn sites enabled"

echo ""
echo "📁 Nginx sites available:"
sudo ls -la /etc/nginx/sites-available/ | grep binh-luan || echo "✅ Không còn cấu hình binh-luan"

echo ""
echo "📁 Thư mục Nginx:"
ls -la /var/www/ | grep binh-luan || echo "✅ Không còn thư mục binh-luan"

# 4. Clone lại từ đầu
echo "=== 4. CLONE LẠI TỪ ĐẦU ==="
echo "📥 Clone repository..."
cd ~
git clone https://github.com/junovestar/Vietscriptsinhton.git sinhton

if [ ! -d "sinhton" ]; then
    echo "❌ Clone thất bại!"
    exit 1
fi

echo "✅ Clone thành công"

# 5. Setup dự án
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

# 9. Tạo cấu hình Nginx mới
echo "⚙️ Tạo cấu hình Nginx..."
sudo tee /etc/nginx/sites-available/binh-luan-generate > /dev/null << 'EOF'
server {
    listen 80;
    server_name tomtat.thanhpn.online www.tomtat.thanhpn.online;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Frontend
    location / {
        root /var/www/binh-luan-generate/dist;
        try_files $uri $uri/ /index.html;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode-block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Backend API
    location /api/ {
        proxy_pass http://localhost:3004;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:3004/health;
    }

    # Security - deny access to sensitive files
    location ~ /\. {
        deny all;
    }
}
EOF

# 10. Enable site
echo "🔗 Enable site..."
sudo ln -sf /etc/nginx/sites-available/binh-luan-generate /etc/nginx/sites-enabled/

# 11. Test cấu hình
echo "🧪 Test cấu hình Nginx..."
if sudo nginx -t; then
    echo "✅ Cấu hình Nginx hợp lệ"
else
    echo "❌ Cấu hình Nginx không hợp lệ"
    sudo nginx -t
    exit 1
fi

# 12. Khởi động services
echo "=== 6. KHỞI ĐỘNG SERVICES ==="
echo "🚀 Khởi động backend..."
pm2 start backend/server.js --name "binh-luan-backend"
pm2 save
pm2 startup

echo "🌐 Khởi động Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# 13. Cấu hình firewall
echo "🔥 Cấu hình firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# 14. Kiểm tra status
echo "=== 7. KIỂM TRA STATUS ==="
sleep 3

echo "📊 PM2 Status:"
pm2 status

echo ""
echo "🌐 Nginx Status:"
sudo systemctl status nginx --no-pager

echo ""
echo "🔍 Test connections:"
# Test backend
curl -s -o /dev/null -w "Backend (localhost:3004): %{http_code}\n" http://localhost:3004/health 2>/dev/null || echo "❌ Backend không phản hồi"

# Test Nginx local
curl -s -o /dev/null -w "Nginx (localhost): %{http_code}\n" http://localhost 2>/dev/null || echo "❌ Nginx local không phản hồi"

# Test domain
echo "🌐 Testing domain: tomtat.thanhpn.online"
curl -s -o /dev/null -w "Domain: %{http_code}\n" http://tomtat.thanhpn.online 2>/dev/null || echo "❌ Domain không phản hồi"

echo ""
echo "✅ Clean All hoàn thành! Thời gian: $(date)"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"
echo "🌐 Website: http://tomtat.thanhpn.online"
