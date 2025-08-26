// Configuration file for Binh Luan Generate By Thanh MKT
export const CONFIG = {
  // Default Gemini API Keys - Đã xóa để thêm lại từ đầu
  DEFAULT_API_KEYS: [],
  
  // Default settings
  DEFAULT_SETTINGS: {
    apiKeys: [],
    prompt: `Bạn là Biên kịch viên YouTube chuyên nghiệp, chuyên viết kịch bản tóm tắt video sinh tồn nơi hoang dã.
Nhiệm vụ: Viết lại transcript thành kịch bản 10 phút, độ dài 4500–5000 chữ, giữ nguyên nội dung chính, chỉ thêm mô tả kịch tính và hài hước.
Yêu cầu: 
- Kể chuyện theo ngôi thứ 3.
- Chỉ xuất ra văn bản kịch bản, KHÔNG thêm ký tự đặc biệt, KHÔNG markdown, KHÔNG format ngoài chữ thường và chữ hoa.
- Nội dung phải bám sát transcript, không thêm chi tiết bên ngoài.
- Kết quả phải là chuỗi text thuần (plain text).`,
    wordCount: 4500,
    writingStyle: 'Hài hước',
    mainCharacter: 'Thánh Nhọ Rừng Sâu',
    language: 'Tiếng Việt',
    creativity: 7
  },
  
  // App info
  APP_INFO: {
    name: 'Binh Luan Generate by Thanh MKT',
    version: '1.0.0',
    description: 'AI-powered YouTube Comment Generator with Radar Interface',
    author: 'Thành MKT'
  },
  
  // Server configuration
  SERVER: {
    frontend_port: 5173,
    backend_port: 3004,
    host: 'localhost'
  }
}
