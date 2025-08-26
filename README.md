# 🎬 Binh Luan Generate By Thành MKT

AI-powered YouTube Comment Generator với giao diện Radar hiện đại, được thiết kế để tự động tạo bình luận sáng tạo cho video YouTube.

![App Preview](preview.png)

## ✨ Tính năng chính

- 🎯 **Radar Interface**: Giao diện radar độc đáo với hiệu ứng phát sáng
- 🤖 **AI-Powered**: Sử dụng Google Gemini API để phân tích video và tạo bình luận
- 🔑 **Pre-configured API**: API key đã được cấu hình sẵn, sẵn sàng sử dụng ngay
- ⚙️ **Tùy chỉnh linh hoạt**: Cài đặt prompt, phong cách viết, độ sáng tạo
- 📊 **Progress Tracking**: Theo dõi tiến trình xử lý real-time với visualization
- 📦 **Batch Processing**: Xử lý đồng thời nhiều video với kết quả tóm gọn
- 📚 **History Management**: Lưu trữ và quản lý lịch sử xử lý với tìm kiếm, lọc
- 📱 **Responsive Design**: Hoạt động mượt mà trên mọi thiết bị
- 🚀 **Workflow Integration**: Bám sát logic của n8n workflow

## 🚀 Cài đặt và sử dụng

### Yêu cầu hệ thống
- Node.js 18+ 
- npm hoặc yarn
- ✅ Google Gemini API key (đã được cấu hình sẵn)

### 1. Clone repository
```bash
git clone <repository-url>
cd binh-luan-generate-by-thanh-mkt
```

### 2. Cài đặt dependencies
```bash
npm install
```

### 3. Sẵn sàng sử dụng
✅ **API Key đã được thiết lập mặc định!**
- Không cần cấu hình thêm gì
- Có thể tùy chỉnh cài đặt khác trong Settings nếu muốn
- Quản lý API keys trong menu "API Keys" trên header

### 4. Chạy ứng dụng
```bash
npm run dev
```

Ứng dụng sẽ chạy trên:
- **Frontend**: http://localhost:5173
- **Backend**: http://localhost:3004

## 🎮 Hướng dẫn sử dụng

### Bước 1: Sẵn sàng sử dụng ngay!
✅ **API Key đã được cấu hình sẵn** - Không cần thiết lập gì thêm!

**Tùy chỉnh cài đặt (tùy chọn):**
1. Mở panel cài đặt (biểu tượng ⚙️)
2. Tùy chỉnh các cài đặt:
   - **Prompt Template**: Mẫu prompt cho AI
   - **Số lượng chữ**: 1000-10000 từ
   - **Phong cách viết**: Hài hước, Nghiêm túc, Kịch tính...
   - **Tên nhân vật chính**: Tùy chỉnh tên nhân vật
   - **Ngôn ngữ**: Tiếng Việt, English, 中文, 日本語
   - **Độ sáng tạo**: 1-10 (càng cao càng sáng tạo)

**💡 Quản lý API Keys:**
- Sử dụng menu "API Keys" trên header để quản lý nhiều API keys
- Hệ thống tự động load balancing và failover

### Bước 2: Thêm video
**Xử lý đơn lẻ:**
1. Click nút **"Thêm Video"**
2. Chọn YouTube URL hoặc Upload File
3. Click **"Bắt Đầu Xử Lý"**

**Xử lý hàng loạt:**
1. Click nút **"Hàng Loạt"** 📦
2. Thêm nhiều video (URL hoặc file)
3. Click **"Bắt Đầu Xử Lý Hàng Loạt"**
4. Theo dõi tiến trình từng video
5. Xem kết quả tóm gọn ngay khi hoàn thành

### Bước 3: Theo dõi tiến trình (Mirror n8n workflow)
**5 bước chính (giống hệt n8n workflow):**

1. **⚡ HTTP Request to Google (Gemini 1.5 Flash)**
   - Prompt: "Determine the total duration of the video in [hh:mm:ss] format."
   - Model: `gemini-1.5-flash`
   - Input: YouTube URL + prompt
   - Output: "The total duration of the video is 00:41:23."
   - **⏳ Delay 1 phút** sau khi hoàn thành

2. **🤖 AI Agent + Gemini 1.5 Flash (thay thế DeepSeek)** 
   - Input: Duration text từ Gemini
   - Prompt: Chia video thành các đoạn 5 phút
   - Model: `gemini-1.5-flash`
   - Output: JSON format với các segments
   - Split Out: Tách thành từng segment

3. **🔄 Loop + Wait1 + HTTP Request to Google1**
   - **Wait1**: 1 phút delay giữa các segment
   - Model: `gemini-2.5-flash` 
   - Xử lý từng segment riêng biệt
   - Extract scene clips cho từng 5 phút

4. **📋 Aggregate Node**
   - Tổng hợp tất cả transcript parts
   - Field: "text" aggregation

5. **⏰ Wait Node (3 phút) + Basic LLM Chain + Gemini 2.5 Pro**
   - **Wait**: 3 phút delay trước final processing
   - Model: `gemini-2.5-pro`
   - Prompt: Workflow's exact long prompt (4500-5000 chữ)
   - Output: Plain text script

**UI Features:**
- **Live Results Sidebar** hiển thị response từng API call
- **Retry Logic** với exponential backoff khi model overload
- **API Key Load Balancing** tự động chuyển đổi khi quá tải
- **Proxy Management** hỗ trợ HTTP, HTTPS, SOCKS4, SOCKS5 với load balancing
- **Progress tracking** cho từng segment processing
- **Error handling** và retry notifications
- **Delay 1 phút** sau bước đầu tiên để tránh rate limiting

### Bước 4: Quản lý API Keys & Proxy (Load Balancing)

**🔑 API Key Manager:**
1. Click nút **"API Keys"** trên header
2. Xem thống kê: Total Keys, Active Keys, Available Keys
3. Thêm/xóa API keys theo nhu cầu
4. Monitor success rate và usage statistics

**🔄 API Key Auto Load Balancing:**
- **Round-robin selection** giữa các keys available
- **Auto failover** khi key bị overload/quota exceeded
- **Exponential backoff cooldown** cho failed keys
- **Real-time switching** không cần restart

**⚠️ API Key Error Handling:**
- `quota_exceeded` → Disable key until reset
- `rate_limit` → Temporary cooldown (1-5 minutes)
- `model_overload` → Switch to next available key
- `invalid_key` → Permanently disable

**🌐 Proxy Manager:**
1. Click nút **"Proxy"** trên header
2. Xem thống kê: Total Proxies, Active Proxies, Available Proxies
3. Thêm/xóa proxy servers (HTTP, HTTPS, SOCKS4, SOCKS5)
4. Test connectivity và response time

**🔄 Proxy Auto Load Balancing:**
- **Round-robin selection** giữa các proxies available
- **Auto failover** khi proxy bị timeout/connection refused
- **Exponential backoff cooldown** cho failed proxies
- **Real-time switching** không cần restart

**⚠️ Proxy Error Handling:**
- `timeout` → Temporary cooldown (30s-5min)
- `connection_refused` → Temporary cooldown
- `authentication_failed` → Permanently disable
- `proxy_unavailable` → Disable until reset

### Bước 5: Xem kết quả
1. Click vào điểm sáng trên radar hoặc nút **"Xem Kết Quả"**
2. Đọc bình luận được tạo (plain text)
3. Click **"Sao Chép"** để copy vào clipboard

### Bước 5: Quản lý lịch sử
1. Click nút **"Lịch Sử"** 📚 để xem tất cả video đã xử lý
2. **Tìm kiếm** theo tiêu đề hoặc nội dung
3. **Lọc** theo loại (đơn lẻ/hàng loạt) và **sắp xếp** theo ngày/tên/độ dài
4. **Xem lại, sao chép, xóa** các kết quả cũ
5. **Xuất dữ liệu** JSON hoặc **xóa toàn bộ** lịch sử

## 🔧 Cấu trúc dự án

```
binh-luan-generate-by-thanh-mkt/
├── src/                      # Frontend React
│   ├── components/           # React components
│   │   ├── Header.jsx       # Header component
│   │   ├── RadarView.jsx    # Radar interface chính
│   │   ├── SettingsPanel.jsx # Panel cài đặt
│   │   ├── InputPanel.jsx   # Panel nhập liệu
│   │   ├── ResultPanel.jsx  # Panel hiển thị kết quả
│   │   ├── ProcessingModal.jsx # Modal tiến trình đơn lẻ
│   │   ├── BatchProcessModal.jsx # Modal setup hàng loạt
│   │   ├── BatchProgressModal.jsx # Modal tiến trình hàng loạt
│   │   ├── BatchFloatingIndicator.jsx # Indicator nổi
│   │   ├── HistoryPanel.jsx # Panel lịch sử xử lý
│   │   ├── HistoryStats.jsx # Thống kê lịch sử
│   │   └── LiveResultsSidebar.jsx # Sidebar kết quả thời gian thực
│   ├── App.jsx              # Main App component
│   ├── main.jsx             # Entry point
│   ├── hooks/               # Custom React hooks
│   │   └── useLocalStorage.js # localStorage management
│   └── index.css            # Global styles
├── backend/                  # Backend Node.js
│   ├── workflows/           # Workflow logic
│   │   └── videoProcessor.js # Main workflow processor
│   ├── services/            # Business logic services
│   │   ├── geminiService.js # Gemini API integration
│   │   ├── timeSegmentService.js # Time segmentation
│   │   ├── scriptGeneratorService.js # Script generation
│   │   ├── transcriptService.js # Transcript handling
│   │   └── progressService.js # Progress tracking
│   ├── utils/               # Utilities
│   │   └── validation.js    # Input validation
│   └── server.js            # Express server
├── package.json             # Dependencies
├── vite.config.js           # Vite configuration
├── tailwind.config.js       # Tailwind CSS config
└── README.md                # This file
```

## 🧠 Workflow Logic

Ứng dụng bám sát workflow n8n gốc với các bước:

1. **Set Transcript Prompt**: Thiết lập prompt lấy độ dài video
2. **HTTP Request to Google**: Gọi Gemini API để xác định duration
3. **AI Agent**: Chia video thành các đoạn 5 phút
4. **Split Out**: Tách các khoảng thời gian
5. **Loop Processing**: Xử lý từng đoạn 5 phút:
   - Set Scene Clips prompt
   - Wait 1 minute (rate limiting)
   - HTTP Request to Google (phân tích đoạn)
   - Edit Fields (trích xuất text)
6. **Aggregate**: Tổng hợp tất cả transcript
7. **Wait 3 minutes**: Chờ trước khi xử lý cuối
8. **Basic LLM Chain**: Tạo bình luận cuối cùng

## 🎨 Theme và Design

### Màu sắc chính
- **Background**: Gradient xanh đậm → tím
- **Accent**: Xanh nhạt phát sáng (#64ffda)
- **Glass Effect**: Backdrop blur với opacity thấp
- **Glow Effects**: Shadow phát sáng cho các element quan trọng

### Animations
- **Radar Pulse**: Hiệu ứng quét radar khi xử lý
- **Ping Ripples**: Hiệu ứng gợn sóng cho video dots
- **Glow Hover**: Hiệu ứng phát sáng khi hover

## 🔗 API Endpoints

### Backend Endpoints
- `GET /health` - Health check
- `POST /api/process` - Xử lý video chính
- `POST /api/upload` - Upload file video

### Request Format
```json
{
  "input": {
    "type": "url",
    "value": "https://youtube.com/watch?v=..."
  },
  "settings": {
    "apiKey": "AIza...",
    "prompt": "...",
    "wordCount": 4500,
    "writingStyle": "Hài hước",
    "mainCharacter": "Thánh Nhọ Rừng Sâu",
    "language": "Tiếng Việt",
    "creativity": 7
  }
}
```

## 🚫 Lưu ý quan trọng

1. **Rate Limiting**: Có delay 1-3 phút giữa các API calls để tránh vượt giới hạn
2. **API Costs**: Gemini API có chi phí, hãy theo dõi usage
3. **Video Length**: Video dài sẽ mất thời gian xử lý lâu hơn
4. **Batch Processing**: Video được xử lý tuần tự (30s delay giữa các video)
5. **File Upload**: Tính năng upload file chưa được implement hoàn toàn

## 🐛 Troubleshooting

### Lỗi API Key
- API key mặc định đã được cấu hình sẵn và hoạt động bình thường
- Nếu gặp lỗi, hãy kiểm tra menu "API Keys" trên header
- Có thể thêm API keys khác để tăng hiệu suất và độ tin cậy

### Lỗi xử lý video
- Kiểm tra URL YouTube có hợp lệ
- Đảm bảo video public và có thể truy cập
- Delay 1 phút sau bước đầu tiên để tránh rate limiting

### Lỗi kết nối
- Kiểm tra internet connection
- Verify backend đang chạy trên port 3001



## 📞 Hỗ trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra console logs (F12)
2. Verify API key và settings
3. Restart ứng dụng nếu cần

## 📄 License

MIT License - Xem file LICENSE để biết thêm chi tiết.

---

**Phát triển bởi Thành MKT** 🚀
