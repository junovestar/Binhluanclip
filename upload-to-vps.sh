#!/bin/bash

# Upload to VPS Script - Upload code lên VPS nhanh chóng
# Cách sử dụng: chmod +x upload-to-vps.sh && ./upload-to-vps.sh

# Cấu hình VPS
VPS_IP="your-vps-ip"
VPS_USER="root"
VPS_PATH="/var/www/binh-luan-generate"

echo "📤 Upload to VPS - Binh Luan Generate By Thanh MKT"

# Kiểm tra tham số
if [ "$1" != "" ]; then
    VPS_IP=$1
fi

if [ "$2" != "" ]; then
    VPS_USER=$2
fi

echo "🎯 Target: $VPS_USER@$VPS_IP:$VPS_PATH"

# Kiểm tra kết nối SSH
echo "🔍 Kiểm tra kết nối SSH..."
if ! ssh -o ConnectTimeout=5 $VPS_USER@$VPS_IP "echo 'SSH connection OK'" 2>/dev/null; then
    echo "❌ Không thể kết nối SSH đến $VPS_IP"
    echo "💡 Kiểm tra:"
    echo "   - IP VPS có đúng không?"
    echo "   - SSH key đã setup chưa?"
    echo "   - Firewall có chặn port 22 không?"
    exit 1
fi

# Tạo backup trên VPS
echo "💾 Tạo backup trên VPS..."
ssh $VPS_USER@$VPS_IP "cd $VPS_PATH && pm2 stop binh-luan-backend 2>/dev/null || true"
ssh $VPS_USER@$VPS_IP "cp -r $VPS_PATH /tmp/binh-luan-backup-\$(date +%Y%m%d-%H%M%S) 2>/dev/null || true"

# Upload code mới (loại trừ node_modules và .git)
echo "📤 Upload code mới..."
rsync -avz --progress \
    --exclude=node_modules \
    --exclude=.git \
    --exclude=dist \
    --exclude=uploads \
    --exclude=*.log \
    ./ $VPS_USER@$VPS_IP:$VPS_PATH/

# Chạy update script trên VPS
echo "🔄 Chạy update script trên VPS..."
ssh $VPS_USER@$VPS_IP "cd $VPS_PATH && chmod +x fast-update.sh && ./fast-update.sh"

echo ""
echo "✅ Upload và update hoàn thành!"
echo "🌐 Truy cập: http://$VPS_IP"
echo "📊 Kiểm tra status: ssh $VPS_USER@$VPS_IP 'pm2 status'"

