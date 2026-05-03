import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'custom_card.dart';
import 'knowledge_hub/crops_info_screen.dart';
import 'knowledge_hub/pests_diseases_info_screen.dart';
import 'knowledge_hub/cultivation_tips_screen.dart';

class LibraryGrid extends StatelessWidget {
  const LibraryGrid({super.key});

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        GestureDetector(
          onTap: () => _navigateToScreen(context, const CropInfoScreen()),
          child: CustomCard(
            title: localizations.crops,
            icon: Icons.grass,
            iconColor: const Color(0xFF4CAF50),
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToScreen(context, const PestsDiseasesInfoScreen()),
          child: CustomCard(
            title: localizations.pestsAndDiseases,
            icon: Icons.bug_report,
            iconColor: const Color(0xFFF44336),
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToScreen(context, const CultivationTipsScreen()),
          child: CustomCard(
            title: localizations.cultivationTips,
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }
}