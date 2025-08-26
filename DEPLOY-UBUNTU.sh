#!/bin/bash

# 🚀 DEPLOY UBUNTU - Binh Luan Generate By Thanh MKT
# Script tự động deploy lên VPS Ubuntu với domain
# Cách sử dụng: chmod +x DEPLOY-UBUNTU.sh && ./DEPLOY-UBUNTU.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function để in thông báo
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE} $1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Kiểm tra quyền sudo
if [ "$EUID" -ne 0 ]; then
    print_error "Vui lòng chạy script với quyền sudo"
    exit 1
fi

print_header "🚀 DEPLOY UBUNTU - Binh Luan Generate"
echo ""

# Nhập thông tin domain
echo -e "${CYAN}Nhập thông tin domain:${NC}"
read -p "Domain của bạn (ví dụ: example.com): " DOMAIN
read -p "Email cho SSL (ví dụ: admin@example.com): " EMAIL

if [ -z "$DOMAIN" ]; then
    print_error "Domain không được để trống!"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    print_error "Email không được để trống!"
    exit 1
fi

print_success "Domain: $DOMAIN"
print_success "Email: $EMAIL"
echo ""

# Bước 1: Cập nhật hệ thống
print_status "Bước 1/10: Cập nhật hệ thống..."
apt update -qq && apt upgrade -y -qq
print_success "Hệ thống đã được cập nhật"

# Bước 2: Cài đặt Node.js 18
print_status "Bước 2/10: Cài đặt Node.js 18..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - > /dev/null 2>&1
    apt-get install -y nodejs > /dev/null 2>&1
    print_success "Node.js $(node --version) đã được cài đặt"
else
    print_warning "Node.js đã được cài đặt: $(node --version)"
fi

# Bước 3: Cài đặt PM2
print_status "Bước 3/10: Cài đặt PM2..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2 > /dev/null 2>&1
    print_success "PM2 đã được cài đặt"
else
    print_warning "PM2 đã được cài đặt"
fi

# Bước 4: Cài đặt Nginx
print_status "Bước 4/10: Cài đặt Nginx..."
if ! command -v nginx &> /dev/null; then
    apt install nginx -y -qq
    systemctl enable nginx > /dev/null 2>&1
    print_success "Nginx đã được cài đặt"
else
    print_warning "Nginx đã được cài đặt"
fi

# Bước 5: Cài đặt Certbot cho SSL
print_status "Bước 5/10: Cài đặt Certbot cho SSL..."
if ! command -v certbot &> /dev/null; then
    apt install certbot python3-certbot-nginx -y -qq
    print_success "Certbot đã được cài đặt"
else
    print_warning "Certbot đã được cài đặt"
fi

# Bước 6: Tạo thư mục dự án
print_status "Bước 6/10: Tạo thư mục dự án..."
PROJECT_DIR="/var/www/binh-luan-generate"
mkdir -p $PROJECT_DIR
chown -R $SUDO_USER:$SUDO_USER $PROJECT_DIR
print_success "Thư mục dự án: $PROJECT_DIR"

# Bước 7: Copy files dự án
print_status "Bước 7/10: Copy files dự án..."
if [ -f "package.json" ]; then
    cp -r . $PROJECT_DIR/ 2>/dev/null || true
    cd $PROJECT_DIR
    print_success "Files dự án đã được copy"
else
    print_warning "Không tìm thấy package.json. Vui lòng upload files dự án vào $PROJECT_DIR"
    cd $PROJECT_DIR
fi

# Bước 8: Cài đặt dependencies và build
print_status "Bước 8/10: Cài đặt dependencies và build..."
if [ -f "package.json" ]; then
    npm install --silent
    npm run build --silent
    print_success "Dependencies đã được cài đặt và build thành công"
else
    print_error "Không tìm thấy package.json. Vui lòng kiểm tra lại files dự án"
    exit 1
fi

# Bước 9: Cấu hình PM2 và Nginx
print_status "Bước 9/10: Cấu hình PM2 và Nginx..."

# Tạo PM2 ecosystem
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

# Khởi động PM2
pm2 delete binh-luan-backend 2>/dev/null || true
pm2 start ecosystem.config.js --silent
pm2 save --silent
pm2 startup --silent

# Cấu hình Nginx với domain
cat > /etc/nginx/sites-available/binh-luan-generate << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript application/x-font-ttf font/opentype image/svg+xml image/x-icon;

    # Frontend
    location / {
        root /var/www/binh-luan-generate/dist;
        try_files \$uri \$uri/ /index.html;
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:3004;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
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
    
    location ~ \.(env|log|sql)$ {
        deny all;
    }
}
EOF

# Enable site và restart Nginx
ln -sf /etc/nginx/sites-available/binh-luan-generate /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t > /dev/null 2>&1 && systemctl restart nginx

# Bước 10: Cấu hình SSL và firewall
print_status "Bước 10/10: Cấu hình SSL và firewall..."

# Cấu hình firewall
ufw allow 22/tcp > /dev/null 2>&1
ufw allow 80/tcp > /dev/null 2>&1
ufw allow 443/tcp > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1

# Lấy SSL certificate
print_status "Đang lấy SSL certificate cho $DOMAIN..."
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $EMAIL

# Lấy IP public
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")

print_success "DEPLOY HOÀN THÀNH!"
echo ""
print_header "🎉 ỨNG DỤNG ĐÃ SẴN SÀNG!"
echo ""
echo "🌐 Truy cập:"
echo "   HTTP:  http://$DOMAIN"
echo "   HTTPS: https://$DOMAIN"
echo "   IP:    http://$PUBLIC_IP"
echo ""
echo "🔧 Health check:"
echo "   https://$DOMAIN/health"
echo ""
echo "📊 QUẢN LÝ:"
echo "   PM2 Status: pm2 status"
echo "   PM2 Logs: pm2 logs binh-luan-backend"
echo "   Restart: pm2 restart binh-luan-backend"
echo "   Nginx Status: systemctl status nginx"
echo "   SSL Status: certbot certificates"
echo ""
echo "🔄 UPDATE SAU NÀY:"
echo "   cd $PROJECT_DIR"
echo "   git pull origin main"
echo "   npm install"
echo "   npm run build"
echo "   pm2 restart binh-luan-backend"
echo ""
echo "🔐 SSL AUTO-RENEWAL:"
echo "   Đã được cấu hình tự động"
echo "   Kiểm tra: crontab -l"
echo ""
print_success "Deploy thành công trong $(($SECONDS / 60)) phút $(($SECONDS % 60)) giây"
echo ""
print_warning "Lưu ý: Có thể mất 5-10 phút để DNS propagate hoàn toàn"
