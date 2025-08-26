# 🚀 Hướng dẫn Deploy lên VPS Ubuntu

## 📋 Yêu cầu hệ thống
- VPS Ubuntu 20.04+ 
- RAM: 2GB+ (khuyến nghị 4GB)
- CPU: 2 cores+
- Disk: 20GB+

## ⚡ Deploy nhanh (5 phút)

### Cách 1: Sử dụng script tự động

```bash
# 1. Kết nối SSH vào VPS
ssh root@your-vps-ip

# 2. Upload files dự án
# Sử dụng scp, rsync hoặc git clone

# 3. Chạy script deploy
chmod +x quick-deploy.sh
./quick-deploy.sh
```

### Cách 2: Deploy thủ công

```bash
# 1. Cài đặt Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Cài đặt PM2
sudo npm install -g pm2

# 3. Cài đặt Nginx
sudo apt install nginx -y

# 4. Tạo thư mục dự án
sudo mkdir -p /var/www/binh-luan-generate
sudo chown $USER:$USER /var/www/binh-luan-generate

# 5. Copy files dự án
# rsync -av --exclude=node_modules --exclude=.git ./ /var/www/binh-luan-generate/

# 6. Cài đặt dependencies
cd /var/www/binh-luan-generate
npm install

# 7. Build frontend
npm run build

# 8. Khởi động với PM2
pm2 start backend/server.js --name "binh-luan-backend"
pm2 save
pm2 startup

# 9. Cấu hình Nginx (copy nội dung từ deploy.sh)
# 10. Restart Nginx
sudo systemctl restart nginx
```

### Cách 3: Sử dụng Docker

```bash
# 1. Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Build và chạy
docker-compose up -d --build
```

## 🔧 Cấu hình SSL (HTTPS)

### Sử dụng Let's Encrypt

```bash
# 1. Cài đặt Certbot
sudo apt install certbot python3-certbot-nginx -y

# 2. Lấy SSL certificate
sudo certbot --nginx -d your-domain.com

# 3. Auto-renewal
sudo crontab -e
# Thêm dòng: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Monitoring và Logs

### PM2 Commands
```bash
# Xem status
pm2 status

# Xem logs
pm2 logs binh-luan-backend

# Restart app
pm2 restart binh-luan-backend

# Monitor real-time
pm2 monit
```

### Nginx Commands
```bash
# Test config
sudo nginx -t

# Restart
sudo systemctl restart nginx

# Xem logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 🔄 Update dự án

```bash
# 1. Backup
cp -r /var/www/binh-luan-generate /var/www/binh-luan-generate-backup

# 2. Pull code mới
cd /var/www/binh-luan-generate
git pull origin main

# 3. Cài đặt dependencies mới
npm install

# 4. Build lại
npm run build

# 5. Restart PM2
pm2 restart binh-luan-backend
```

## 🚨 Troubleshooting

### Lỗi thường gặp

1. **Port 3004 đã được sử dụng**
```bash
sudo lsof -i :3001
sudo kill -9 <PID>
```

2. **Nginx không start**
```bash
sudo nginx -t
sudo systemctl status nginx
```

3. **PM2 app không start**
```bash
pm2 logs binh-luan-backend
pm2 delete binh-luan-backend
pm2 start ecosystem.config.js
```

4. **Permission denied**
```bash
sudo chown -R $USER:$USER /var/www/binh-luan-generate
sudo chmod -R 755 /var/www/binh-luan-generate
```

## 📈 Performance Optimization

### Nginx Optimization
```nginx
# Thêm vào nginx.conf
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
client_max_body_size 100M;
```

### PM2 Optimization
```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'binh-luan-backend',
    script: 'backend/server.js',
    instances: 'max', // Sử dụng tất cả CPU cores
    exec_mode: 'cluster',
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
}
```

## 🔐 Security

### Firewall
```bash
# Chỉ mở ports cần thiết
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 3001/tcp # Không expose backend port
```

### Fail2ban
```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `pm2 logs` và `sudo nginx -t`
2. Kiểm tra status: `pm2 status` và `sudo systemctl status nginx`
3. Kiểm tra ports: `sudo netstat -tlnp`
4. Kiểm tra firewall: `sudo ufw status`
