import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permission
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location with high accuracy
  static Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Check and request permission
    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied. Please allow location access.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 60),
      forceAndroidLocationManager: false,
    );
  }

  // Get location with timeout fallback
  static Future<Position> getCurrentLocationWithFallback() async {
    try {
      final position = await getCurrentLocation();
      return position;
    } catch (e) {
      // Return default location (Panmalewadi, Maharashtra) if GPS fails
      print('GPS failed, using default location: $e');

      // Create a default position with all required parameters
      return Position(
        longitude: 73.986088,
        latitude: 17.750670,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }
}