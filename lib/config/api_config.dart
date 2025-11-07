/// JSONBin.io API Configuration
/// للحصول على API Key: https://jsonbin.io
class ApiConfig {
  // API Key من JSONBin.io (سجل حساب مجاني واحصل عليه)
  static const String jsonBinApiKey = r'$2a$10$2htRva94IdDmgGz8ZvUqs.mAh7gRW7lyhoiexIJYqV/Ux6SbnctHi';
  
  // Bin IDs (سيتم إنشاؤها تلقائياً أول مرة)
  static const String questionsBinId = '690db924ae596e708f4a0789'; // للأسئلة
  static const String usersBinId = '690db8c9d0ea881f40d949a9'; // للمستخدمين
  
  // Base URL
  static const String baseUrl = 'https://api.jsonbin.io/v3';
}
