import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.eco),
          label: localizations.myCrops,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.store),
          label: localizations.market,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: localizations.me,
        ),
      ],
    );
  }
}