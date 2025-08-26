#!/bin/bash

# Deploy Tomtat Script - Deploy dự án cho tomtat.thanhpn.online
# Cách sử dụng: chmod +x deploy-tomtat.sh && ./deploy-tomtat.sh

echo "🚀 Deploy Tomtat - Binh Luan Generate By Thanh MKT"
echo "🕐 Bắt đầu: $(date)"
echo "🌐 Domain: tomtat.thanhpn.online"
echo "📥 Repository: https://github.com/junovestar/Vietscriptsinhton"
echo ""

# 1. Clone repository
echo "=== 1. CLONE REPOSITORY ==="
cd ~
git clone https://github.com/junovestar/Vietscriptsinhton.git sinhton

if [ ! -d "sinhton" ]; then
    echo "❌ Clone thất bại!"
    exit 1
fi

echo "✅ Clone thành công"

# 2. Vào thư mục dự án
echo "=== 2. SETUP DỰ ÁN ==="
cd sinhton

# Tìm thư mục dự án (có thể nested)
if [ -d "Vietscriptsinhton" ]; then
    cd Vietscriptsinhton
    if [ -d "Vietscriptsinhton" ]; then
        cd Vietscriptsinhton
    fi
fi

echo "📁 Thư mục hiện tại: $(pwd)"

# 3. Cài đặt dependencies
echo "📦 Cài đặt dependencies..."
npm install

# 4. Build frontend
echo "🔨 Build frontend..."
npm run build

# 5. Tạo thư mục Nginx
echo "📋 Setup Nginx..."
sudo mkdir -p /var/www/binh-luan-generate
sudo cp -r dist /var/www/binh-luan-generate/
sudo chown -R www-data:www-data /var/www/binh-luan-generate/
sudo chmod -R 755 /var/www/binh-luan-generate/

# 6. Tạo cấu hình Nginx
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

# 7. Enable site
echo "🔗 Enable site..."
sudo ln -sf /etc/nginx/sites-available/binh-luan-generate /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 8. Test cấu hình
echo "🧪 Test cấu hình Nginx..."
if sudo nginx -t; then
    echo "✅ Cấu hình Nginx hợp lệ"
else
    echo "❌ Cấu hình Nginx không hợp lệ"
    sudo nginx -t
    exit 1
fi

# 9. Khởi động services
echo "=== 3. KHỞI ĐỘNG SERVICES ==="
echo "🚀 Khởi động backend..."
pm2 start backend/server.js --name "binh-luan-backend"
pm2 save
pm2 startup

echo "🌐 Khởi động Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# 10. Cấu hình firewall
echo "🔥 Cấu hình firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# 11. Kiểm tra status
echo "=== 4. KIỂM TRA STATUS ==="
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
echo "✅ Deploy Tomtat hoàn thành! Thời gian: $(date)"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"
echo "🌐 Website: http://tomtat.thanhpn.online"

# Hướng dẫn SSL
echo ""
echo "🔒 Để setup SSL (HTTPS):"
echo "sudo apt install certbot python3-certbot-nginx -y"
echo "sudo certbot --nginx -d tomtat.thanhpn.online"
