//



import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final Widget? actionWidget; // Optional custom action widget

  const AppHeader({
    super.key,
    this.onMenuPressed,
    this.showMenuButton = false,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: const Color(0xFFF5F7F3),
      elevation: 0,
      title: Row(
        children: [
          // Simple icon image without circles
          _buildMiniLogo(),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: localizations.neural,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: localizations.field,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (actionWidget != null) actionWidget!,
        if (showMenuButton)
          GestureDetector(
            onTap: onMenuPressed,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu,
                size: 20,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniLogo() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Image.asset(
        'assets/icon/lc_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackMiniLogo();
        },
      ),
    );
  }

  Widget _buildFallbackMiniLogo() {
    return const Center(
      child: Icon(
        Icons.agriculture,
        size: 28,
        color: Color(0xFF4CAF50),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}