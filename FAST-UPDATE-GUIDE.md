# ⚡ Hướng dẫn Update Nhanh Nhất lên VPS Ubuntu

## 🎯 Các cách update nhanh nhất

### Cách 1: Update trực tiếp trên VPS (Nhanh nhất - 2-3 phút)

```bash
# 1. SSH vào VPS
ssh root@your-vps-ip

# 2. Chạy script update nhanh
cd /var/www/binh-luan-generate
chmod +x fast-update.sh
./fast-update.sh
```

### Cách 2: Update từ máy local (5-7 phút)

```bash
# 1. Commit và push code mới
git add .
git commit -m "Update version"
git push origin main

# 2. Upload và update lên VPS
chmod +x upload-to-vps.sh
./upload-to-vps.sh your-vps-ip root
```

### Cách 3: Update bằng Windows (5-7 phút)

```batch
# 1. Chạy script Windows
quick-update.bat your-vps-ip root
```

## 🚀 Script Update Nhanh

### fast-update.sh
- ⚡ Thời gian: 2-3 phút
- 💾 Backup tự động
- 🔄 Restart nhanh
- 🧹 Tự động dọn dẹp

### upload-to-vps.sh
- 📤 Upload code mới
- 🔄 Chạy update tự động
- ✅ Kiểm tra kết nối
- 📊 Hiển thị status

## 📋 Quy trình Update

1. **Backup nhanh** (30 giây)
   - Backup thư mục `dist` và `backend`
   - Lưu vào `/tmp/`

2. **Pull code mới** (30 giây)
   - `git fetch origin`
   - `git reset --hard origin/main`

3. **Cài đặt dependencies** (1 phút)
   - `npm install --production`

4. **Build frontend** (1 phút)
   - `npm run build`

5. **Restart services** (30 giây)
   - Restart PM2
   - Reload Nginx

## 🔧 Cấu hình nhanh

### Cấu hình VPS IP
```bash
# Sửa file upload-to-vps.sh
VPS_IP="your-actual-vps-ip"
VPS_USER="root"
```

### Cấu hình Git
```bash
# Đảm bảo Git đã setup
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## 🚨 Troubleshooting

### Lỗi thường gặp

1. **SSH connection failed**
```bash
# Kiểm tra IP và SSH key
ssh -o ConnectTimeout=5 root@your-vps-ip
```

2. **Permission denied**
```bash
# Fix permission
sudo chown -R $USER:$USER /var/www/binh-luan-generate
```

3. **Port already in use**
```bash
# Kill process
sudo lsof -i :3004
sudo kill -9 <PID>
```

4. **Build failed**
```bash
# Clean và rebuild
rm -rf node_modules package-lock.json
npm install
npm run build
```

## 📊 Monitoring

### Kiểm tra status
```bash
# PM2 status
pm2 status

# Nginx status
sudo systemctl status nginx

# Logs
pm2 logs binh-luan-backend
```

### Rollback nhanh
```bash
# Nếu update bị lỗi
pm2 stop binh-luan-backend
rm -rf /var/www/binh-luan-generate
mv /tmp/binh-luan-backup-* /var/www/binh-luan-generate
cd /var/www/binh-luan-generate
pm2 start backend/server.js --name "binh-luan-backend"
```

## ⚡ Tips tối ưu

1. **Sử dụng rsync** thay vì scp để upload nhanh hơn
2. **Backup chỉ những file quan trọng** để tiết kiệm thời gian
3. **Sử dụng PM2 cluster mode** để tăng performance
4. **Cache npm dependencies** trên VPS
5. **Sử dụng CDN** cho static files

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `pm2 logs binh-luan-backend`
2. Kiểm tra status: `pm2 status`
3. Kiểm tra Nginx: `sudo nginx -t`
4. Kiểm tra ports: `sudo netstat -tlnp`

---

**Thời gian update trung bình: 2-5 phút** ⚡
