import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../api/api_response.dart';
import '../services/location_service.dart';
import '../services/location_helper.dart';
import '../services/cache_manager.dart';   // ✅ added

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherService _weatherService = WeatherService();
  final CacheManager _cache = CacheManager();   // ✅ cache manager instance

  // ---------- Cache duration ----------
  static const _cacheDuration = Duration(minutes: 10);

  // ---------- UI state ----------
  WeatherResponse? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String _locationName = '';
  bool _isLocationLoading = true;
  double? _currentLat;
  double? _currentLon;

  // Flag to avoid showing loading indicator during a background refresh
  bool _isBackgroundRefresh = false;

  @override
  void initState() {
    super.initState();
    _initializeWithCache();
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  /// Called once when the widget is created.
  /// Shows cached data instantly if available & fresh, then refreshes in background.
  void _initializeWithCache() async {
    // 1. Do we have a valid cache?
    final bool hasValidCache = _cache.cachedWeather != null &&
        _cache.cachedLocationName != null &&
        _cache.weatherTimestamp != null &&
        DateTime.now().difference(_cache.weatherTimestamp!) < _cacheDuration &&
        _cache.cachedWeather!.status;

    if (hasValidCache) {
      // Show cached data immediately – no loading spinner
      setState(() {
        _weatherData = _cache.cachedWeather;
        _locationName = _cache.cachedLocationName!;
        _currentLat = _cache.cachedLat;
        _currentLon = _cache.cachedLon;
        _isLoading = false;
        _isLocationLoading = false;
        _errorMessage = null;
      });

      // 2. Refresh in background if cache is getting old or location might have changed
      _performBackgroundRefresh();
    } else {
      // No cache – do full fetch with loading indicator
      await _fetchLocationAndWeather(forceRefresh: true);
    }
  }

  /// Background refresh: fetches fresh data without showing a loader.
  /// Only updates the UI if new data is different from cached.
  Future<void> _performBackgroundRefresh() async {
    if (_isBackgroundRefresh) return;
    _isBackgroundRefresh = true;

    try {
      // Check location services & permissions (no UI change on error)
      final hasLocationService = await LocationService.isLocationServiceEnabled();
      final hasPermission = await LocationService.requestPermission();

      if (!hasLocationService || !hasPermission) {
        _isBackgroundRefresh = false;
        return;
      }

      final position = await LocationService.getCurrentLocationWithFallback();
      final newLat = position.latitude;
      final newLon = position.longitude;

      // Check if location changed significantly (approx 1.1 km)
      final bool locationChanged = _cache.cachedLat != null && _cache.cachedLon != null &&
          ((newLat - _cache.cachedLat!).abs() > 0.01 ||
              (newLon - _cache.cachedLon!).abs() > 0.01);

      final bool cacheExpired = _cache.weatherTimestamp == null ||
          DateTime.now().difference(_cache.weatherTimestamp!) > _cacheDuration;

      if (!locationChanged && !cacheExpired) {
        // Location same and cache still fresh – nothing to do
        _isBackgroundRefresh = false;
        return;
      }

      // Get fresh location name and weather
      final locationDetails = await LocationHelper.getFullLocationDetails(
        newLat,
        newLon,
      );

      String displayLocation = '';
      if (locationDetails['city'] != null && locationDetails['city']!.isNotEmpty) {
        displayLocation = locationDetails['city']!;
        if (locationDetails['state'] != null && locationDetails['state']!.isNotEmpty) {
          displayLocation += ', ${locationDetails['state']}';
        }
      } else if (locationDetails['state'] != null && locationDetails['state']!.isNotEmpty) {
        displayLocation = locationDetails['state']!;
      } else {
        displayLocation = '${newLat.toStringAsFixed(2)}, ${newLon.toStringAsFixed(2)}';
      }

      final weather = await _weatherService.getWeatherByCoordinates(
        lat: newLat,
        lon: newLon,
      );

      // Update cache and UI (only if still mounted)
      if (mounted) {
        setState(() {
          _cache.cachedWeather = weather;
          _cache.cachedLocationName = displayLocation;
          _cache.cachedLat = newLat;
          _cache.cachedLon = newLon;
          _cache.weatherTimestamp = DateTime.now();

          _weatherData = weather;
          _locationName = displayLocation;
          _currentLat = newLat;
          _currentLon = newLon;
          _errorMessage = null;
        });
      }
    } catch (e) {
      // Silently fail – the user still sees cached data
      debugPrint('Background weather refresh failed: $e');
    } finally {
      _isBackgroundRefresh = false;
    }
  }

  /// Full fetch with loading indicator.
  /// Called by the refresh button or when no cache exists.
  Future<void> _fetchLocationAndWeather({bool forceRefresh = false}) async {
    setState(() {
      if (forceRefresh) {
        _isLoading = true;
        _isLocationLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final hasLocationService = await LocationService.isLocationServiceEnabled();
      final hasPermission = await LocationService.requestPermission();

      if (!hasLocationService || !hasPermission) {
        throw Exception(AppLocalizations.of(context)!.locationServicesUnavailable);
      }

      final position = await LocationService.getCurrentLocationWithFallback();
      _currentLat = position.latitude;
      _currentLon = position.longitude;

      final locationDetails = await LocationHelper.getFullLocationDetails(
        _currentLat!,
        _currentLon!,
      );

      String displayLocation = '';
      if (locationDetails['city'] != null && locationDetails['city']!.isNotEmpty) {
        displayLocation = locationDetails['city']!;
        if (locationDetails['state'] != null && locationDetails['state']!.isNotEmpty) {
          displayLocation += ', ${locationDetails['state']}';
        }
      } else if (locationDetails['state'] != null && locationDetails['state']!.isNotEmpty) {
        displayLocation = locationDetails['state']!;
      } else {
        displayLocation = '${_currentLat!.toStringAsFixed(2)}, ${_currentLon!.toStringAsFixed(2)}';
      }

      final weather = await _weatherService.getWeatherByCoordinates(
        lat: _currentLat!,
        lon: _currentLon!,
      );

      // Update cache via CacheManager
      _cache.cachedWeather = weather;
      _cache.cachedLocationName = displayLocation;
      _cache.cachedLat = _currentLat;
      _cache.cachedLon = _currentLon;
      _cache.weatherTimestamp = DateTime.now();

      if (mounted) {
        setState(() {
          _weatherData = weather;
          _locationName = displayLocation;
          _isLoading = false;
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Location/Weather error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.locationServiceUnavailableEnableGps;
          _isLoading = false;
          _isLocationLoading = false;
        });
      }
    }
  }

  Future<void> _refreshWeather() async {
    await _fetchLocationAndWeather(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildContent(localizations),
    );
  }

  Widget _buildContent(AppLocalizations localizations) {
    if (_isLoading || _isLocationLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4CAF50)),
            const SizedBox(height: 12),
            Text(
              localizations.detectingLocation,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7B6A)),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.enableGpsForAccurateWeather,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 48, color: Color(0xFFF44336)),
            const SizedBox(height: 12),
            Text(
              localizations.locationServiceRequired,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E2B)),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7B6A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshWeather,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(localizations.enableLocationAndRetry),
            ),
          ],
        ),
      );
    }

    if (_weatherData != null && _weatherData!.status) {
      final weather = _weatherData!.data.weather;
      final wind = _weatherData!.data.wind;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Text(
                        _locationName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7B6A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(context),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getWeatherColor(weather.condition).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getWeatherIcon(weather.condition),
                  color: _getWeatherColor(weather.condition),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.temperature.toInt().toString(),
                style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700, color: Color(0xFF2C3E2B)),
              ),
              const Text(
                '°C',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFF6B7B6A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizations.feelsLike} ${weather.feelsLikeString}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2C3E2B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '💧 ${localizations.humidityLabel} ${weather.humidity}%',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7B6A)),
                      ),
                      Text(
                        '💨 ${localizations.windLabel} ${wind.speedString}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7B6A)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getWeatherIcon(weather.condition),
                  size: 20,
                  color: _getWeatherColor(weather.condition),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${weather.condition.toUpperCase()} • ${_getSprayingAdvice(context, weather.temperature, weather.humidity)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2C3E2B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _refreshWeather,
              icon: const Icon(Icons.gps_fixed, size: 18),
              label: Text(
                localizations.refreshWeather,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ---- Helper methods (unchanged) ----
  String _getFormattedDate(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final monthNames = [
      localizations.monthJan,
      localizations.monthFeb,
      localizations.monthMar,
      localizations.monthApr,
      localizations.monthMay,
      localizations.monthJun,
      localizations.monthJul,
      localizations.monthAug,
      localizations.monthSep,
      localizations.monthOct,
      localizations.monthNov,
      localizations.monthDec,
    ];
    final month = monthNames[now.month - 1];
    return '${now.day} $month ${now.year}';
  }

  String _getSprayingAdvice(BuildContext context, double temp, int humidity) {
    final localizations = AppLocalizations.of(context)!;
    if (temp > 35) return localizations.sprayingAdviceTooHot;
    if (temp < 15) return localizations.sprayingAdviceLowTemp;
    if (humidity > 80) return localizations.sprayingAdviceHighHumidity;
    if (humidity < 30) return localizations.sprayingAdviceLowHumidity;
    return localizations.sprayingAdviceGood;
  }

  IconData _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) return Icons.wb_sunny;
    if (conditionLower.contains('cloud')) return Icons.cloud;
    if (conditionLower.contains('rain')) return Icons.umbrella;
    if (conditionLower.contains('thunder')) return Icons.flash_on;
    if (conditionLower.contains('mist') || conditionLower.contains('fog')) return Icons.foggy;
    return Icons.wb_cloudy;
  }

  Color _getWeatherColor(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) return const Color(0xFFFFB74D);
    if (conditionLower.contains('cloud')) return const Color(0xFF9E9E9E);
    if (conditionLower.contains('rain')) return const Color(0xFF64B5F6);
    if (conditionLower.contains('thunder')) return const Color(0xFFFF6B6B);
    return const Color(0xFF81C784);
  }
}