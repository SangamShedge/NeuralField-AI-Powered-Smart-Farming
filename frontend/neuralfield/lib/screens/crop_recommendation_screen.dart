// lib/screens/crop_recommendation_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../api/api_response.dart';

// Green Theme Constants for Crop Recommendation
class GreenTheme {
  static const Color primary = Color(0xFF4CAF50);      // Main Green
  static const Color primaryLight = Color(0xFFE8F5E9); // Light Green BG
  static const Color primaryDark = Color(0xFF388E3C);  // Dark Green
  static const Color accent = Color(0xFFC8E6C9);       // Accent Green
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color textDark = Color(0xFF2C3E2B);     // Dark Text
  static const Color textLight = Color(0xFF4A5B49);    // Light Text
  static const Color gradientStart = Color(0xFFE8F5E9);
  static const Color gradientEnd = Color(0xFFC8E6C9);
}

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final CropRecommendationService _cropService = CropRecommendationService();

  final _formKey = GlobalKey<FormState>();
  String _selectedLocation = 'Satara';
  String _selectedSoilType = 'Loamy';
  String _selectedWater = 'Medium';
  String _selectedSeason = 'Kharif';
  String _selectedPreviousCrop = 'None';
  String _selectedGoal = 'Profit';

  bool _isLoading = false;
  CropRecommendationResponse? _recommendation;
  String? _errorMessage;

  final List<String> _locations = [
    'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Buldhana', 'Jalgaon', 'Kolhapur', 'Latur', 'Nagpur', 'Nanded', 'Nashik', 'Osmanabad', 'Parbhani', 'Pune', 'Sangli', 'Satara', 'Solapur', 'Wardha', 'Yavatmal'
  ];
  final List<String> _soilTypes = ['Alluvial', 'Black', 'Clay', 'Laterite', 'Loamy', 'Red', 'Sandy'];
  final List<String> _waterOptions = ['High', 'Low', 'Medium', 'Very High'];
  final List<String> _seasons = ['Kharif', 'Rabi', 'Summer'];
  final List<String> _previousCrops = ['None', 'Bajra', 'Chickpea', 'Cotton', 'Groundnut', 'Jowar', 'Maize', 'Rice', 'Soybean', 'Sugarcane', 'Tur', 'Wheat'];
  final List<String> _goals = ['FastGrowth', 'HighYield', 'LowCost', 'Profit'];

  @override
  void dispose() {
    _cropService.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recommendation = null;
    });

    try {
      final result = await _cropService.getCropRecommendations(
        location: _selectedLocation,
        soilType: _selectedSoilType,
        water: _selectedWater.toLowerCase(),
        season: _selectedSeason,
        previousCrop: _selectedPreviousCrop.toLowerCase(),
        goal: _selectedGoal,
      );

      setState(() {
        _recommendation = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _recommendation = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: Text(
          localizations.cropRecommendationAppBarTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GreenTheme.textDark,
          ),
        ),
        backgroundColor: const Color(0xFFF5F7F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GreenTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_recommendation != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: GreenTheme.primary),
              onPressed: _resetForm,
              tooltip: localizations.newRecommendationTooltip,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GreenTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.analyzingFarmData,
              style: const TextStyle(color: Color(0xFF6B7B6A)),
            ),
          ],
        ),
      )
          : _recommendation != null
          ? _buildResultsScreen()
          : _buildInputForm(),
    );
  }

  Widget _buildInputForm() {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(
              icon: Icons.agriculture,
              title: localizations.aiPoweredRecommendationsTitle,
              subtitle: localizations.aiPoweredRecommendationsSubtitle,
            ),
            const SizedBox(height: 20),
            Container(
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
              child: Column(
                children: [
                  _buildDropdownField(
                    label: localizations.locationLabel,
                    icon: Icons.location_on,
                    value: _selectedLocation,
                    items: _locations,
                    onChanged: (value) => setState(() => _selectedLocation = value!),
                    getDisplayName: (value) => value, // location names stay as is
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.soilTypeLabel,
                    icon: Icons.landscape,
                    value: _selectedSoilType,
                    items: _soilTypes,
                    onChanged: (value) => setState(() => _selectedSoilType = value!),
                    getDisplayName: (value) => _getLocalizedSoilType(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.waterAvailabilityLabel,
                    icon: Icons.water_drop,
                    value: _selectedWater,
                    items: _waterOptions,
                    onChanged: (value) => setState(() => _selectedWater = value!),
                    getDisplayName: (value) => _getLocalizedWaterOption(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.seasonLabel,
                    icon: Icons.wb_sunny,
                    value: _selectedSeason,
                    items: _seasons,
                    onChanged: (value) => setState(() => _selectedSeason = value!),
                    getDisplayName: (value) => _getLocalizedSeason(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.previousCropLabel,
                    icon: Icons.agriculture,
                    value: _selectedPreviousCrop,
                    items: _previousCrops,
                    onChanged: (value) => setState(() => _selectedPreviousCrop = value!),
                    getDisplayName: (value) => _getLocalizedPreviousCrop(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.goalLabel,
                    icon: Icons.trending_up,
                    value: _selectedGoal,
                    items: _goals,
                    onChanged: (value) => setState(() => _selectedGoal = value!),
                    getDisplayName: (value) => _getLocalizedGoal(context, value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _getRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GreenTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  localizations.getRecommendationsButton,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Crop Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [GreenTheme.primary, GreenTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: GreenTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    _getCropIcon(_recommendation!.primaryCrop),
                    size: 120,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.recommendedForYouBadge,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _recommendation!.primaryCrop,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              localizations.bestMatchBadge,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getLocalizedGoal(context, _selectedGoal),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Other Suggestions
          if (_recommendation!.otherCrops.isNotEmpty) ...[
            Text(
              localizations.otherSuggestionsTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: GreenTheme.textDark),
            ),
            const SizedBox(height: 12),
            ..._recommendation!.otherCrops.map((crop) => _buildSuggestionCard(crop)),
          ],

          const SizedBox(height: 20),

          // Input Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GreenTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GreenTheme.accent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: GreenTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      localizations.inputSummaryTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: GreenTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSummaryChip('📍 $_selectedLocation'),
                    _buildSummaryChip('🌱 ${_getLocalizedSoilType(context, _selectedSoilType)}'),
                    _buildSummaryChip('💧 ${_getLocalizedWaterOption(context, _selectedWater)}'),
                    _buildSummaryChip('☀️ ${_getLocalizedSeason(context, _selectedSeason)}'),
                    _buildSummaryChip('🌾 ${_getLocalizedPreviousCrop(context, _selectedPreviousCrop)}'),
                    _buildSummaryChip('💰 ${_getLocalizedGoal(context, _selectedGoal)}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(localizations.newAnalysisButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GreenTheme.primary,
                    side: BorderSide(color: GreenTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _getRecommendations,
                  icon: const Icon(Icons.save_alt, size: 18),
                  label: Text(localizations.saveButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GreenTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String crop) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GreenTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCropIcon(crop), size: 24, color: GreenTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: GreenTheme.textDark)),
                const SizedBox(height: 4),
                Text(localizations.suggestionSubtext, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GreenTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_forward_ios, size: 14, color: GreenTheme.primary),
          ),
        ],
      ),
    );
  }

  // Shared UI Components
  Widget _buildHeaderCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GreenTheme.gradientStart, GreenTheme.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GreenTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GreenTheme.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: GreenTheme.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String Function(String) getDisplayName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: GreenTheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            onChanged: onChanged,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(getDisplayName(item), style: const TextStyle(fontWeight: FontWeight.w500)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GreenTheme.accent),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: GreenTheme.textLight)),
    );
  }

  // Helper methods to get localized display names for dropdown values (API values remain English)
  String _getLocalizedSoilType(BuildContext context, String soilType) {
    final localizations = AppLocalizations.of(context)!;
    switch (soilType) {
      case 'Alluvial': return localizations.soilTypeAlluvial;
      case 'Black': return localizations.soilTypeBlack;
      case 'Clay': return localizations.soilTypeClay;
      case 'Laterite': return localizations.soilTypeLaterite;
      case 'Loamy': return localizations.soilTypeLoamy;
      case 'Red': return localizations.soilTypeRed;
      case 'Sandy': return localizations.soilTypeSandy;
      default: return soilType;
    }
  }

  String _getLocalizedWaterOption(BuildContext context, String water) {
    final localizations = AppLocalizations.of(context)!;
    switch (water) {
      case 'High': return localizations.waterHigh;
      case 'Low': return localizations.waterLow;
      case 'Medium': return localizations.waterMedium;
      case 'Very High': return localizations.waterVeryHigh;
      default: return water;
    }
  }

  String _getLocalizedSeason(BuildContext context, String season) {
    final localizations = AppLocalizations.of(context)!;
    switch (season) {
      case 'Kharif': return localizations.seasonKharif;
      case 'Rabi': return localizations.seasonRabi;
      case 'Summer': return localizations.seasonSummer;
      default: return season;
    }
  }

  String _getLocalizedPreviousCrop(BuildContext context, String crop) {
    final localizations = AppLocalizations.of(context)!;
    switch (crop) {
      case 'None': return localizations.previousCropNone;
      case 'Bajra': return localizations.previousCropBajra;
      case 'Chickpea': return localizations.previousCropChickpea;
      case 'Cotton': return localizations.previousCropCotton;
      case 'Groundnut': return localizations.previousCropGroundnut;
      case 'Jowar': return localizations.previousCropJowar;
      case 'Maize': return localizations.previousCropMaize;
      case 'Rice': return localizations.previousCropRice;
      case 'Soybean': return localizations.previousCropSoybean;
      case 'Sugarcane': return localizations.previousCropSugarcane;
      case 'Tur': return localizations.previousCropTur;
      case 'Wheat': return localizations.previousCropWheat;
      default: return crop;
    }
  }

  String _getLocalizedGoal(BuildContext context, String goal) {
    final localizations = AppLocalizations.of(context)!;
    switch (goal) {
      case 'FastGrowth': return localizations.goalFastGrowth;
      case 'HighYield': return localizations.goalHighYield;
      case 'LowCost': return localizations.goalLowCost;
      case 'Profit': return localizations.goalProfit;
      default: return goal;
    }
  }

  IconData _getCropIcon(String crop) {
    switch (crop.toLowerCase()) {
      case 'wheat': return Icons.grass;
      case 'rice': return Icons.agriculture;
      case 'maize': return Icons.earbuds;
      case 'soybean': return Icons.eco;
      case 'sugarcane': return Icons.science;
      case 'chickpea': return Icons.circle;
      case 'jowar': return Icons.grain;
      default: return Icons.agriculture;
    }
  }
}