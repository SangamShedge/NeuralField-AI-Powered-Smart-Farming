// lib/api/api_urls.dart
class Urls {
  // static const String baseUrl = 'http://127.0.0.1:8000';         // Localhost
  // static const String baseUrl = 'http://192.168.0.183:8000';     // Router
  // static const String baseUrl = 'http://10.226.40.233:8000';        // Mobile Hotspot
  // static const String baseUrl = 'http://DESKTOP-OLRHJ27:8000';
  static const String baseUrl = 'https://crummy-gestation-unrigged.ngrok-free.dev';

  // Media URL helper
  static String getMediaUrl(String path) {
    // Remove leading slash if present
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  // Helper method to build full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Auth Endpoints
  static const String register = '/users/register/';
  static const String sendOtp = '/users/send-otp/';
  static const String verifyOtp = '/users/verify-otp/';
  static const String login = '/users/login/';
  static const String logout = '/users/logout/';
  static const String tokenRefresh = '/users/token/refresh/';
  static const String forgotPassword = '/users/forgot-password/';
  static const String resetPassword = '/users/reset-password/';
  static const String profileDetail = '/users/profile/';
  static const String updateProfile = '/users/update-profile/';

  // AI Endpoints
  static const String weather = '/ai/weather/';
  static const String cropRecommendation = '/ai/crop-recommend/';
  static const String fertilizerRecommendation = '/ai/fertilizer-recommend/';
  static const String npkCalculator = '/ai/npk-calculator/';
  static const String pestDetection = '/ai/pest-detection/';
  static const String agricultureNews = '/ai/agriculture-news/';
  static const String geminiChat = '/ai/gemini-chat/';

  // Market Endpoints
  static const String marketMeta = '/markets/mandi/meta/';
  static const String marketDashboard = '/markets/mandi/dashboard/';
  static const String marketPrices = '/markets/mandi/prices/';
  static const String marketComparison = '/markets/mandi/comparison/';
  // static const String marketHistory = '/markets/mandi/history/';

  // Crop Endpoints
  static const String cropCreate = '/crops/my_crop/create/';
  static const String cropList = '/crops/my_crop/list/';
  static const String cropUpdate = '/crops/my_crop/update/';
  static const String cropSoftDelete = '/crops/my_crop/soft_delete/';

  // Crop notes
  static const String cropNoteCreate = '/crops/crop_note/create/';
  static const String cropNoteList = '/crops/crop_note/list/';
  static const String cropNoteUpdate = '/crops/crop_note/update/';
  static const String cropNoteSoftDelete = '/crops/crop_note/soft_delete/';

  // Knowledge Hub Endpoints
  static const String cropEncyclopedia = '/knowledge_hub/crops/';
  static const String cultivationTips = '/knowledge_hub/cultivation/';
  static const String pests = '/knowledge_hub/pests/';
  static const String diseases = '/knowledge_hub/diseases/';

}