// lib/services/logout_service.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../screens/login_screen.dart';
import '../services/cache_manager.dart';
import '../l10n/app_localizations.dart';

class LogoutService {
  /// Shows confirmation dialog, clears cache, calls API logout, and navigates to LoginScreen.
  static Future<void> logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.of(context)!.logoutConfirmTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(AppLocalizations.of(context)!.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await _executeLogout(context);
    }
  }

  static Future<void> _executeLogout(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.loggingOut),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Clear all caches
      CacheManager().clearAll();

      // Call API logout
      final loginService = LoginService();
      await loginService.logout();

      if (context.mounted) Navigator.pop(context); // close loading dialog

      if (context.mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // close loading dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorLogout} ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}