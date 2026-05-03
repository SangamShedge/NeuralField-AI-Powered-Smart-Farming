// lib/services/cache_manager.dart
import '../api/api_response.dart';          // for NewsItem, for WeatherResponse, for ProfileDataWrapper
import '../widgets/voice_input_fab.dart';   // for ChatMessage
import '../screens/crops_screen.dart';      // for Crop

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // --- News cache ---
  List<NewsItem> cachedNews = [];
  DateTime? newsTimestamp;

  // --- Weather cache ---
  WeatherResponse? cachedWeather;
  String? cachedLocationName;
  double? cachedLat;
  double? cachedLon;
  DateTime? weatherTimestamp;

  // --- Chat cache ---
  List<ChatMessage> cachedChatMessages = [];
  bool chatInitialized = false;

  // --- Profile cache ---
  ProfileDataWrapper? cachedProfileWrapper;

  // --- Crops cache ---
  List<Crop> cachedCrops = [];
  bool cropsInitialized = false;

  /// Clears all caches stored in the app.
  void clearAll() {
    // News
    cachedNews = [];
    newsTimestamp = null;

    // Weather
    cachedWeather = null;
    cachedLocationName = null;
    cachedLat = null;
    cachedLon = null;
    weatherTimestamp = null;

    // Chat
    cachedChatMessages = [];
    chatInitialized = false;

    // Profile
    cachedProfileWrapper = null;

    // Crops
    cachedCrops = [];
    cropsInitialized = false;
  }
}