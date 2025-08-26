#!/bin/bash

# Update Deploy Script - Cập nhật dự án lên VPS Ubuntu
# Cách sử dụng: chmod +x update-deploy.sh && ./update-deploy.sh

echo "🔄 Update Deploy - Binh Luan Generate By Thanh MKT"

# Kiểm tra thư mục dự án
PROJECT_DIR="/var/www/binh-luan-generate"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Thư mục dự án không tồn tại: $PROJECT_DIR"
    echo "💡 Hãy chạy quick-deploy.sh trước"
    exit 1
fi

# Backup dự án hiện tại
BACKUP_DIR="/var/www/binh-luan-generate-backup-$(date +%Y%m%d-%H%M%S)"
echo "💾 Backup dự án hiện tại: $BACKUP_DIR"
cp -r $PROJECT_DIR $BACKUP_DIR

# Dừng PM2 process
echo "⏸️ Dừng PM2 process..."
pm2 stop binh-luan-backend 2>/dev/null || true

# Chuyển đến thư mục dự án
cd $PROJECT_DIR

# Pull code mới từ Git (nếu sử dụng Git)
if [ -d ".git" ]; then
    echo "📥 Pull code mới từ Git..."
    git fetch origin
    git reset --hard origin/main
else
    echo "⚠️ Không tìm thấy Git repository"
    echo "💡 Hãy upload files mới thủ công"
fi

# Cài đặt dependencies mới
echo "📦 Cài đặt dependencies mới..."
npm install

# Build lại frontend
echo "🔨 Build lại frontend..."
npm run build

# Cập nhật PM2 ecosystem (nếu có thay đổi)
echo "⚙️ Cập nhật PM2 ecosystem..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'binh-luan-backend',
    script: 'backend/server.js',
    cwd: '/var/www/binh-luan-generate',
    env: {
      NODE_ENV: 'production',
      PORT: 3004
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
}
EOF

# Khởi động lại PM2
echo "🚀 Khởi động lại backend..."
pm2 delete binh-luan-backend 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

# Cập nhật cấu hình Nginx (nếu cần)
echo "⚙️ Cập nhật cấu hình Nginx..."
sudo tee /etc/nginx/sites-available/binh-luan-generate > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        root /var/www/binh-luan-generate/dist;
        try_files $uri $uri/ /index.html;
    }

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
    }

    location /health {
        proxy_pass http://localhost:3004/health;
    }
}
EOF

# Restart Nginx
echo "🔄 Restart Nginx..."
sudo nginx -t && sudo systemctl restart nginx

# Kiểm tra status
echo "📊 Kiểm tra status..."
sleep 3
pm2 status
echo ""

# Kiểm tra logs
echo "📋 Logs gần đây:"
pm2 logs binh-luan-backend --lines 10

echo ""
echo "✅ Update hoàn thành!"
echo "🌐 Truy cập: http://$(curl -s ifconfig.me)"
echo "💾 Backup: $BACKUP_DIR"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"

# Hướng dẫn rollback nếu cần
echo ""
echo "🔄 Nếu cần rollback:"
echo "pm2 stop binh-luan-backend"
echo "rm -rf $PROJECT_DIR"
echo "mv $BACKUP_DIR $PROJECT_DIR"
echo "cd $PROJECT_DIR && pm2 start ecosystem.config.js"

