# 🚀 Hướng dẫn Deploy lên VPS Ubuntu

## 📋 Yêu cầu hệ thống
- VPS Ubuntu 20.04+ 
- RAM: 2GB+ (khuyến nghị 4GB)
- CPU: 2 cores+
- Disk: 20GB+
- Domain đã trỏ về IP VPS

## ⚡ Deploy nhanh (10 phút)

### Bước 1: Chuẩn bị VPS
```bash
# Kết nối SSH vào VPS
ssh root@your-vps-ip

# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y
```

### Bước 2: Upload dự án
```bash
# Cách 1: Git clone (nhanh nhất)
git clone https://github.com/your-repo/binh-luan-generate.git
cd binh-luan-generate

# Cách 2: Upload bằng scp
scp -r ./ root@your-vps-ip:/root/binh-luan-generate
cd binh-luan-generate

# Cách 3: Upload bằng rsync
rsync -av --exclude=node_modules --exclude=.git ./ root@your-vps-ip:/root/binh-luan-generate/
```

### Bước 3: Chạy script deploy
```bash
# Cấp quyền và chạy
chmod +x DEPLOY-UBUNTU.sh
./DEPLOY-UBUNTU.sh
```

### Bước 4: Nhập thông tin
Script sẽ hỏi bạn:
- **Domain**: Ví dụ: `example.com`
- **Email**: Ví dụ: `admin@example.com`

## ✅ Kết quả sau 10 phút

- ✅ **Node.js 18+** đã cài đặt
- ✅ **PM2** quản lý process
- ✅ **Nginx** reverse proxy với gzip
- ✅ **SSL Certificate** tự động (Let's Encrypt)
- ✅ **Frontend** build và serve
- ✅ **Backend** chạy trên port 3001
- ✅ **Firewall** đã cấu hình
- ✅ **Security headers** đã thêm
- ✅ **Domain** accessible qua HTTPS

## 🌐 Truy cập ứng dụng

- **HTTPS**: `https://your-domain.com`
- **HTTP**: `http://your-domain.com` (redirect to HTTPS)
- **Health check**: `https://your-domain.com/health`

## 📊 Lệnh quản lý

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

### SSL Commands
```bash
# Xem certificates
certbot certificates

# Renew SSL
certbot renew

# Test renewal
certbot renew --dry-run
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

1. **Port 3001 đã được sử dụng**
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

4. **SSL certificate lỗi**
```bash
certbot certificates
certbot --nginx -d your-domain.com --force-renewal
```

5. **Permission denied**
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
5. Kiểm tra SSL: `certbot certificates`

## 🎯 Lưu ý quan trọng

1. **DNS**: Đảm bảo domain đã trỏ về IP VPS trước khi chạy script
2. **Email**: Sử dụng email thật để nhận thông báo SSL
3. **Backup**: Luôn backup trước khi update
4. **Monitoring**: Sử dụng PM2 monit để theo dõi performance
5. **Logs**: Kiểm tra logs thường xuyên để phát hiện lỗi sớm
