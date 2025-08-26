#!/bin/bash

# Deploy script for Binh Luan Generate By Thanh MKT
# Chạy trên VPS Ubuntu

echo "🚀 Bắt đầu deploy dự án lên VPS Ubuntu..."

# Cập nhật hệ thống
echo "📦 Cập nhật hệ thống..."
sudo apt update && sudo apt upgrade -y

# Cài đặt Node.js 18+
echo "📦 Cài đặt Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Cài đặt PM2 để quản lý process
echo "📦 Cài đặt PM2..."
sudo npm install -g pm2

# Cài đặt Nginx
echo "📦 Cài đặt Nginx..."
sudo apt install nginx -y

# Tạo thư mục cho dự án
echo "📁 Tạo thư mục dự án..."
sudo mkdir -p /var/www/binh-luan-generate
sudo chown $USER:$USER /var/www/binh-luan-generate

# Copy files dự án (giả sử đã upload)
echo "📋 Copy files dự án..."
# cp -r * /var/www/binh-luan-generate/

# Cài đặt dependencies
echo "📦 Cài đặt dependencies..."
cd /var/www/binh-luan-generate
npm install

# Build frontend
echo "🔨 Build frontend..."
npm run build

# Tạo file PM2 ecosystem
echo "⚙️ Tạo PM2 ecosystem..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
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
    }
  ]
}
EOF

# Khởi động backend với PM2
echo "🚀 Khởi động backend..."
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Cấu hình Nginx
echo "⚙️ Cấu hình Nginx..."
sudo tee /etc/nginx/sites-available/binh-luan-generate << 'EOF'
server {
    listen 80;
    server_name your-domain.com; # Thay đổi domain của bạn

    # Frontend
    location / {
        root /var/www/binh-luan-generate/dist;
        try_files $uri $uri/ /index.html;
    }

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
    }

    # Health check
    location /health {
        proxy_pass http://localhost:3004/health;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/binh-luan-generate /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test và restart Nginx
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Cấu hình firewall
echo "🔥 Cấu hình firewall..."
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

echo "✅ Deploy hoàn thành!"
echo "🌐 Truy cập: http://your-domain.com"
echo "📊 PM2 Status: pm2 status"
echo "📋 Logs: pm2 logs"
