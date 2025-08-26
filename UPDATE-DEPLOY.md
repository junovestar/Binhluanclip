# 🔄 Hướng dẫn Cập nhật Dự án lên VPS Ubuntu

## 📋 Tổng quan
Hướng dẫn cập nhật phiên bản mới nhất của dự án lên VPS Ubuntu đã được deploy trước đó.

## 🚀 Cách 1: Sử dụng Script Tự động (Khuyến nghị)

### Bước 1: Chuẩn bị files
```bash
# Trên máy local
chmod +x upload-to-vps.sh
./upload-to-vps.sh
```

### Bước 2: Nhập thông tin VPS
- IP VPS
- Username (mặc định: root)

### Bước 3: Script sẽ tự động:
- Upload files mới
- Chạy update script trên VPS
- Restart services

## 🔧 Cách 2: Update thủ công trên VPS

### Bước 1: Kết nối SSH vào VPS
```bash
ssh root@your-vps-ip
```

### Bước 2: Upload files mới
```bash
# Từ máy local
rsync -avz --exclude=node_modules --exclude=.git ./ root@your-vps-ip:/var/www/binh-luan-generate/
```

### Bước 3: Chạy update script trên VPS
```bash
# Trên VPS
cd /var/www/binh-luan-generate
chmod +x update-deploy.sh
./update-deploy.sh
```

## 🔄 Cách 3: Update qua Git (Nếu dùng Git)

### Bước 1: Push code mới lên Git
```bash
# Trên máy local
git add .
git commit -m "Update to latest version"
git push origin main
```

### Bước 2: Pull trên VPS
```bash
# Trên VPS
cd /var/www/binh-luan-generate
git pull origin main
chmod +x update-deploy.sh
./update-deploy.sh
```

## 📊 Kiểm tra sau khi update

### Kiểm tra PM2
```bash
pm2 status
pm2 logs binh-luan-backend
```

### Kiểm tra Nginx
```bash
sudo nginx -t
sudo systemctl status nginx
```

### Kiểm tra ports
```bash
sudo netstat -tlnp | grep :3004
sudo netstat -tlnp | grep :80
```

### Test API
```bash
curl http://localhost:3004/api/keys/stats
curl http://your-vps-ip/api/keys/stats
```

## 🔄 Rollback nếu có lỗi

### Bước 1: Dừng service
```bash
pm2 stop binh-luan-backend
```

### Bước 2: Restore backup
```bash
# Tìm backup gần nhất
ls -la /var/www/binh-luan-generate-backup-*

# Restore
rm -rf /var/www/binh-luan-generate
mv /var/www/binh-luan-generate-backup-YYYYMMDD-HHMMSS /var/www/binh-luan-generate
```

### Bước 3: Khởi động lại
```bash
cd /var/www/binh-luan-generate
pm2 start ecosystem.config.js
```

## 🚨 Troubleshooting

### Lỗi thường gặp

1. **Port 3004 đã được sử dụng**
```bash
sudo lsof -i :3004
sudo kill -9 <PID>
```

2. **Permission denied**
```bash
sudo chown -R $USER:$USER /var/www/binh-luan-generate
sudo chmod -R 755 /var/www/binh-luan-generate
```

3. **Nginx không start**
```bash
sudo nginx -t
sudo systemctl restart nginx
```

4. **PM2 app không start**
```bash
pm2 logs binh-luan-backend
pm2 delete binh-luan-backend
pm2 start ecosystem.config.js
```

5. **Dependencies lỗi**
```bash
rm -rf node_modules package-lock.json
npm install
```

## 📈 Monitoring

### Xem logs real-time
```bash
pm2 logs binh-luan-backend --lines 100 -f
```

### Monitor performance
```bash
pm2 monit
```

### Kiểm tra disk space
```bash
df -h
du -sh /var/www/binh-luan-generate*
```

## 🔐 Security Checklist

- [ ] Backup trước khi update
- [ ] Kiểm tra logs sau update
- [ ] Test API endpoints
- [ ] Kiểm tra SSL certificate (nếu có)
- [ ] Verify firewall rules

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `pm2 logs` và `sudo nginx -t`
2. Kiểm tra status: `pm2 status` và `sudo systemctl status nginx`
3. Kiểm tra ports: `sudo netstat -tlnp`
4. Rollback về version cũ nếu cần

## 🎯 Best Practices

1. **Luôn backup trước khi update**
2. **Test trên staging trước production**
3. **Update vào giờ ít traffic**
4. **Monitor logs sau update**
5. **Có plan rollback sẵn sàng**



