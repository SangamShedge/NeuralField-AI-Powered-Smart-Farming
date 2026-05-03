import 'package:geocoding/geocoding.dart';

class LocationHelper {
  // Convert coordinates to human-readable address
  static Future<String> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String name = place.name ?? '';
        String locality = place.locality ?? '';
        String subLocality = place.subLocality ?? '';
        String administrativeArea = place.administrativeArea ?? '';
        String country = place.country ?? '';

        // Try to get the most specific location name
        String locationName = '';

        if (locality.isNotEmpty && administrativeArea.isNotEmpty) {
          locationName = '$locality, $administrativeArea';
        } else if (subLocality.isNotEmpty && administrativeArea.isNotEmpty) {
          locationName = '$subLocality, $administrativeArea';
        } else if (administrativeArea.isNotEmpty) {
          locationName = administrativeArea;
        } else if (locality.isNotEmpty) {
          locationName = locality;
        } else if (name.isNotEmpty) {
          locationName = name;
        } else {
          locationName = '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
        }

        print('📍 Geocoding result: $locationName');
        return locationName;
      } else {
        return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
      }
    } catch (e) {
      print('Geocoding error: $e');
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    }
  }

  // Get just the city name
  static Future<String> getCityFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subLocality ?? place.administrativeArea ?? 'Unknown';
        print('📍 City: $city');
        return city;
      }
      return 'Unknown';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Unknown';
    }
  }

  // Get full location details
  static Future<Map<String, String>> getFullLocationDetails(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String locality = place.locality ?? '';
        String subLocality = place.subLocality ?? '';
        String administrativeArea = place.administrativeArea ?? '';
        String country = place.country ?? '';

        // Build a clean address
        String fullAddress = '';
        if (locality.isNotEmpty && administrativeArea.isNotEmpty) {
          fullAddress = '$locality, $administrativeArea';
        } else if (subLocality.isNotEmpty && administrativeArea.isNotEmpty) {
          fullAddress = '$subLocality, $administrativeArea';
        } else if (administrativeArea.isNotEmpty) {
          fullAddress = administrativeArea;
        } else if (locality.isNotEmpty) {
          fullAddress = locality;
        } else {
          fullAddress = '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
        }

        print('📍 Full address: $fullAddress');

        return {
          'city': locality.isNotEmpty ? locality : (subLocality.isNotEmpty ? subLocality : administrativeArea),
          'state': administrativeArea,
          'country': country,
          'fullAddress': fullAddress,
        };
      }
      return {
        'city': '',
        'state': '',
        'country': '',
        'fullAddress': '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}',
      };
    } catch (e) {
      print('Geocoding error: $e');
      return {
        'city': '',
        'state': '',
        'country': '',
        'fullAddress': '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}',
      };
    }
  }
}