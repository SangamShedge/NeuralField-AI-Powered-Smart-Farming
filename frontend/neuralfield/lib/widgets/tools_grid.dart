import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'custom_card.dart';
import '../screens/crop_recommendation_screen.dart';
import '../screens/fertilizer_recommendation_screen.dart';
import '../screens/pest_detection_screen.dart';
import '../screens/fertilizer_calculator_screen.dart';

class ToolsGrid extends StatelessWidget {
  const ToolsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Crop Recommendation Card with navigation
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CropRecommendationScreen(),
              ),
            );
          },
          child: CustomCard(
            title: localizations.cropRecommendationTitle,
            subtitle: localizations.cropRecommendationSubtitle,
            icon: Icons.agriculture,
            iconColor: const Color(0xFF4CAF50),
          ),
        ),

        // Fertilizer Recommendation Card with navigation
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FertilizerRecommendationScreen(),
              ),
            );
          },
          child: CustomCard(
            title: localizations.fertilizerRecommendationTitle,
            subtitle: localizations.fertilizerRecommendationSubtitle,
            icon: Icons.science,
            iconColor: const Color(0xFF9C27B0),
          ),
        ),

        // Fertilizer Calculator
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FertilizerCalculatorScreen(),
              ),
            );
          },
          child: CustomCard(
            title: localizations.fertilizerCalculatorTitle,
            subtitle: localizations.fertilizerCalculatorSubtitle,
            icon: Icons.calculate,
            iconColor: const Color(0xFFFF9800),
          ),
        ),

        // Pest Detection Card with navigation (UPDATED)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PestDetectionScreen(),
              ),
            );
          },
          child: CustomCard(
            title: localizations.pestDetectionTitle,
            subtitle: localizations.pestDetectionSubtitle,
            icon: Icons.camera_alt_outlined,
            iconColor: const Color(0xFFF44336),
          ),
        ),
      ],
    );
  }
}