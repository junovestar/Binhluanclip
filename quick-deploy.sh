#!/bin/bash

# Quick Deploy Script - Chạy trên VPS Ubuntu
# Cách sử dụng: chmod +x quick-deploy.sh && ./quick-deploy.sh

echo "🚀 Quick Deploy - Binh Luan Generate By Thanh MKT"

# Kiểm tra Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Cài đặt Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Kiểm tra PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 Cài đặt PM2..."
    sudo npm install -g pm2
fi

# Kiểm tra Nginx
if ! command -v nginx &> /dev/null; then
    echo "📦 Cài đặt Nginx..."
    sudo apt install nginx -y
fi

# Tạo thư mục dự án
PROJECT_DIR="/var/www/binh-luan-generate"
echo "📁 Tạo thư mục: $PROJECT_DIR"
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

# Copy files (giả sử đã upload)
echo "📋 Copy files dự án..."
# rsync -av --exclude=node_modules --exclude=.git ./ $PROJECT_DIR/

# Cài đặt dependencies
echo "📦 Cài đặt dependencies..."
cd $PROJECT_DIR
npm install

# Build frontend
echo "🔨 Build frontend..."
npm run build

# Tạo PM2 ecosystem
echo "⚙️ Tạo PM2 ecosystem..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'binh-luan-backend',
    script: 'backend/server.js',
    cwd: '/var/www/binh-luan-generate',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
}
EOF

# Khởi động với PM2
echo "🚀 Khởi động backend..."
pm2 delete binh-luan-backend 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Cấu hình Nginx
echo "⚙️ Cấu hình Nginx..."
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

# Enable site
sudo ln -sf /etc/nginx/sites-available/binh-luan-generate /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Restart Nginx
sudo nginx -t && sudo systemctl restart nginx

# Cấu hình firewall
echo "🔥 Cấu hình firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "✅ Deploy hoàn thành!"
echo "🌐 Truy cập: http://$(curl -s ifconfig.me)"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs binh-luan-backend"
