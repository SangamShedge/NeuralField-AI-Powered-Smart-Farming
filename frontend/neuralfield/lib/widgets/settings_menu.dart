// lib/widgets/settings_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../screens/login_screen.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/cache_manager.dart';
import '../services/logout_service.dart';

class SettingsMenu {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            _buildDivider(),
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              title: AppLocalizations.of(context)!.settings,
              subtitle: AppLocalizations.of(context)!.settingsSubtitle,
              onTap: () => _handleSettings(context),
            ),
            _buildDivider(),
            _buildMenuItem(
              context: context,
              icon: Icons.notifications_none_outlined,
              title: AppLocalizations.of(context)!.notifications,
              subtitle: AppLocalizations.of(context)!.notificationsSubtitle,
              onTap: () => _handleNotifications(context),
            ),
            _buildDivider(),
            _buildMenuItem(
              context: context,
              icon: Icons.help_outline,
              title: AppLocalizations.of(context)!.helpSupport,
              subtitle: AppLocalizations.of(context)!.helpSupportSubtitle,
              onTap: () => _handleHelp(context),
            ),
            _buildDivider(),
            _buildMenuItem(
              context: context,
              icon: Icons.info_outline,
              title: AppLocalizations.of(context)!.about,
              subtitle: AppLocalizations.of(context)!.aboutSubtitle,
              onTap: () => _handleAbout(context),
            ),
            _buildDivider(),
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: AppLocalizations.of(context)!.logout,
              subtitle: AppLocalizations.of(context)!.logoutSubtitle,
              onTap: () => _handleLogout(context),
              isLogout: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(AppLocalizations.of(context)!.selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.english),
            trailing: currentLocale.languageCode == 'en'
                ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                : null,
            onTap: () {
              Navigator.pop(context);
              localeProvider.setLocale(const Locale('en'));
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.hindi),
            trailing: currentLocale.languageCode == 'hi'
                ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                : null,
            onTap: () {
              Navigator.pop(context);
              localeProvider.setLocale(const Locale('hi'));
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.marathi),
            trailing: currentLocale.languageCode == 'mr'
                ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                : null,
            onTap: () {
              Navigator.pop(context);
              localeProvider.setLocale(const Locale('mr'));
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }

  static void _handleSettings(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Builder(
          builder: (newContext) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DragHandle(),
                  _buildDivider(),
                  _buildMenuItem(
                    context: newContext,
                    icon: Icons.language,
                    title: AppLocalizations.of(newContext)!.language,
                    subtitle: AppLocalizations.of(newContext)!.changeLanguage,
                    onTap: () {
                      Navigator.pop(newContext);
                      showDialog(
                        context: newContext,
                        useRootNavigator: true,
                        builder: (dialogContext) => _buildLanguageDialog(dialogContext),
                      );
                    },
                  ),
                  _buildDivider(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void _handleNotifications(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.notificationsComingSoon),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _handleHelp(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.helpSupportComingSoon),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _handleAbout(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.aboutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.agriculture, size: 48, color: Color(0xFF4CAF50)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.appName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.smartFarmingPlatform, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context)!.version} 1.0.0', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Do NOT pop the bottom sheet before calling logout.
  static Future<void> _handleLogout(BuildContext context) async {
    // The logout service will show its own confirmation dialog.
    // The bottom sheet will remain but will be dismissed automatically
    // when the app navigates to the login screen.
    await LogoutService.logout(context);
  }

  // Kept for compatibility if called from elsewhere.
  static Future<void> logout(BuildContext context) async {
    await LogoutService.logout(context);
  }

  static Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: isLogout ? Colors.red : const Color(0xFF4CAF50)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : const Color(0xFF2C3E2B),
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: Icon(Icons.chevron_right, size: 20, color: isLogout ? Colors.red : Colors.grey.shade400),
      onTap: onTap,
    );
  }

  static Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}