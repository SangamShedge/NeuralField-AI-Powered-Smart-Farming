import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';

class PermissionService {
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Permission denied, can request again
      return false;
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      await openAppSettings();
      return false;
    }

    return false;
  }

  // Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }

  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location service to be enabled
  static Future<bool> requestLocationService() async {
    return await Geolocator.openLocationSettings();
  }

  // Complete permission check with user guidance
  static Future<bool> ensureLocationAccess(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool result = await _showLocationServiceDialog(context);
      if (!result) return false;
      serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return false;
    }

    // Check and request permission
    bool permissionGranted = await isLocationPermissionGranted();
    if (!permissionGranted) {
      permissionGranted = await requestLocationPermission();
      if (!permissionGranted) {
        await _showPermissionDeniedDialog(context);
        return false;
      }
    }

    return true;
  }

  static Future<bool> _showLocationServiceDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.locationServicesRequired),
          content: Text(localizations.locationServicesRequiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: Text(localizations.enable),
            ),
          ],
        );
      },
    );

    if (result == true) {
      return await requestLocationService();
    }

    return false;
  }

  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.permissionRequired),
          content: Text(localizations.permissionRequiredMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: Text(localizations.openSettings),
            ),
          ],
        );
      },
    );
  }
}