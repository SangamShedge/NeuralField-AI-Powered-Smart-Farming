// lib/screens/fertilizer_recommendation_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../api/api_response.dart';

// Purple Color Theme Constants
class PurpleTheme {
  static const Color primary = Color(0xFF9C27B0);      // Main Purple
  static const Color primaryLight = Color(0xFFF3E5F5); // Light Purple BG
  static const Color primaryDark = Color(0xFF7B1FA2);  // Dark Purple
  static const Color accent = Color(0xFFE1BEE7);       // Accent Purple
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color textDark = Color(0xFF2C3E2B);     // Dark Text
  static const Color textLight = Color(0xFF4A5B49);    // Light Text
}

class FertilizerOptions {
  static const List<String> crops = [
    'bajra', 'chickpea', 'cotton', 'grapes', 'groundnut',
    'jowar', 'maize', 'millet', 'onion', 'pomegranate',
    'potato', 'rice', 'soybean', 'sugarcane', 'sunflower',
    'tomato', 'tur', 'wheat'
  ];
  static const List<String> growthStages = [
    'seedling', 'vegetative', 'flowering', 'fruiting', 'maturity'
  ];
  static const List<String> soilTypes = ['alluvial', 'black', 'clay', 'loamy', 'red', 'sandy'];
  static const List<String> plantConditions = [
    'healthy', 'slow growth', 'yellow leaves', 'pale leaves', 'brown spots', 'weak stem'
  ];
  static const List<String> irrigationTypes = ['canal', 'borewell', 'drip', 'sprinkler', 'rain'];
  static const List<String> soilMoistures = ['low', 'medium', 'high'];
}

class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() => _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState extends State<FertilizerRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fertilizerService = FertilizerRecommendationService();

  bool _isLoading = false;
  FertilizerRecommendationResponse? _recommendation;
  String? _errorMessage;

  String _selectedCrop = 'tomato';
  int _cropAge = 30;
  String _selectedGrowthStage = 'vegetative';
  String _selectedSoilType = 'loamy';
  String _selectedPlantCondition = 'slow growth';
  String _selectedIrrigationType = 'canal';
  double _temperature = 25.0;
  String _selectedSoilMoisture = 'medium';

  @override
  void dispose() {
    _fertilizerService.dispose();
    super.dispose();
  }

  Future<void> _getRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _fertilizerService.getFertilizerRecommendation(
        crop: _selectedCrop,
        cropAge: _cropAge,
        growthStage: _selectedGrowthStage,
        soilType: _selectedSoilType,
        plantCondition: _selectedPlantCondition,
        irrigationType: _selectedIrrigationType,
        temperature: _temperature,
        soilMoisture: _selectedSoilMoisture,
      );

      setState(() {
        _recommendation = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.errorPrefix} ${e.toString()}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
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
          localizations.fertilizerRecommendationAppBarTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E2B)),
        ),
        backgroundColor: const Color(0xFFF5F7F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_recommendation != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: PurpleTheme.primary),
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
              valueColor: AlwaysStoppedAnimation<Color>(PurpleTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(localizations.analyzingCropText, style: const TextStyle(color: Color(0xFF6B7B6A))),
          ],
        ),
      )
          : _recommendation != null
          ? _buildRecommendationView()
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
              icon: Icons.science,
              title: localizations.aiPoweredAnalysisTitle,
              subtitle: localizations.aiPoweredAnalysisSubtitle,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildDropdownField(
                    label: localizations.cropTypeLabel,
                    icon: Icons.agriculture,
                    value: _selectedCrop,
                    items: FertilizerOptions.crops,
                    onChanged: (value) => setState(() => _selectedCrop = value!),
                    getDisplayName: (value) => _getLocalizedCrop(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildSliderField(
                    label: localizations.cropAgeLabel,
                    icon: Icons.calendar_today,
                    value: _cropAge.toDouble(),
                    min: 0,
                    max: 365,
                    divisions: 73,
                    onChanged: (value) => setState(() => _cropAge = value.toInt()),
                    valueText: '${_cropAge} ${localizations.daysLabel}',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.growthStageLabel,
                    icon: Icons.timeline,
                    value: _selectedGrowthStage,
                    items: FertilizerOptions.growthStages,
                    onChanged: (value) => setState(() => _selectedGrowthStage = value!),
                    getDisplayName: (value) => _getLocalizedGrowthStage(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.soilTypeLabel,
                    icon: Icons.landscape,
                    value: _selectedSoilType,
                    items: FertilizerOptions.soilTypes,
                    onChanged: (value) => setState(() => _selectedSoilType = value!),
                    getDisplayName: (value) => _getLocalizedSoilType(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.plantConditionLabel,
                    icon: Icons.local_florist,
                    value: _selectedPlantCondition,
                    items: FertilizerOptions.plantConditions,
                    onChanged: (value) => setState(() => _selectedPlantCondition = value!),
                    getDisplayName: (value) => _getLocalizedPlantCondition(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.irrigationTypeLabel,
                    icon: Icons.water_drop,
                    value: _selectedIrrigationType,
                    items: FertilizerOptions.irrigationTypes,
                    onChanged: (value) => setState(() => _selectedIrrigationType = value!),
                    getDisplayName: (value) => _getLocalizedIrrigationType(context, value),
                  ),
                  const SizedBox(height: 16),
                  _buildSliderField(
                    label: localizations.temperatureLabel,
                    icon: Icons.thermostat,
                    value: _temperature,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (value) => setState(() => _temperature = value),
                    valueText: '${_temperature.toStringAsFixed(1)}°C',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: localizations.soilMoistureLabel,
                    icon: Icons.opacity,
                    value: _selectedSoilMoisture,
                    items: FertilizerOptions.soilMoistures,
                    onChanged: (value) => setState(() => _selectedSoilMoisture = value!),
                    getDisplayName: (value) => _getLocalizedSoilMoisture(context, value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _getRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PurpleTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(localizations.getFertilizerRecommendationButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationView() {
    final localizations = AppLocalizations.of(context)!;
    final data = _recommendation!.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Fertilizer Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [PurpleTheme.primary, PurpleTheme.primaryDark]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: PurpleTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Text(data.getFertilizerIcon(), style: const TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  Text(data.fertilizer, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(data.fertilizerCategory, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recommendation Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.agriculture, color: PurpleTheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(localizations.applicationDetailsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B))),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(icon: Icons.science, label: localizations.fertilizerLabel, value: data.fertilizer, color: PurpleTheme.primary),
                const SizedBox(height: 16),
                _buildInfoRow(icon: Icons.agriculture, label: localizations.quantityLabel, value: data.quantity, color: PurpleTheme.primary),
                const SizedBox(height: 16),
                _buildInfoRow(icon: Icons.description, label: localizations.recommendationLabel, value: data.recommendation, color: PurpleTheme.primary, multiline: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Input Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PurpleTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PurpleTheme.accent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: PurpleTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(localizations.inputSummaryTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E2B))),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSummaryChip('🌾 ${_getLocalizedCrop(context, _selectedCrop)}'),
                    _buildSummaryChip('📅 $_cropAge ${localizations.daysLabel}'),
                    _buildSummaryChip('🌱 ${_getLocalizedGrowthStage(context, _selectedGrowthStage)}'),
                    _buildSummaryChip('🏞️ ${_getLocalizedSoilType(context, _selectedSoilType)}'),
                    _buildSummaryChip('🌿 ${_getLocalizedPlantCondition(context, _selectedPlantCondition)}'),
                    _buildSummaryChip('💧 ${_getLocalizedIrrigationType(context, _selectedIrrigationType)}'),
                    _buildSummaryChip('🌡️ ${_temperature.toStringAsFixed(1)}°C'),
                    _buildSummaryChip('💦 ${_getLocalizedSoilMoisture(context, _selectedSoilMoisture)}'),
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
                    foregroundColor: PurpleTheme.primary,
                    side: BorderSide(color: PurpleTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.savedMessage), backgroundColor: PurpleTheme.primary),
                    );
                  },
                  icon: const Icon(Icons.save_alt, size: 18),
                  label: Text(localizations.saveButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PurpleTheme.primary,
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

  // Helper: localize dropdown display values (API values remain English)
  String _getLocalizedCrop(BuildContext context, String crop) {
    final localizations = AppLocalizations.of(context)!;
    switch (crop) {
      case 'bajra': return localizations.cropBajra;
      case 'chickpea': return localizations.cropChickpea;
      case 'cotton': return localizations.cropCotton;
      case 'grapes': return localizations.cropGrapes;
      case 'groundnut': return localizations.cropGroundnut;
      case 'jowar': return localizations.cropJowar;
      case 'maize': return localizations.cropMaize;
      case 'millet': return localizations.cropMillet;
      case 'onion': return localizations.cropOnion;
      case 'pomegranate': return localizations.cropPomegranate;
      case 'potato': return localizations.cropPotato;
      case 'rice': return localizations.cropRice;
      case 'soybean': return localizations.cropSoybean;
      case 'sugarcane': return localizations.cropSugarcane;
      case 'sunflower': return localizations.cropSunflower;
      case 'tomato': return localizations.cropTomato;
      case 'tur': return localizations.cropTur;
      case 'wheat': return localizations.cropWheat;
      default: return crop;
    }
  }

  String _getLocalizedGrowthStage(BuildContext context, String stage) {
    final localizations = AppLocalizations.of(context)!;
    switch (stage) {
      case 'seedling': return localizations.stageSeedling;
      case 'vegetative': return localizations.stageVegetative;
      case 'flowering': return localizations.stageFlowering;
      case 'fruiting': return localizations.stageFruiting;
      case 'maturity': return localizations.stageMaturity;
      default: return stage;
    }
  }

  String _getLocalizedSoilType(BuildContext context, String soil) {
    final localizations = AppLocalizations.of(context)!;
    switch (soil) {
      case 'alluvial': return localizations.soilAlluvial;
      case 'black': return localizations.soilBlack;
      case 'clay': return localizations.soilClay;
      case 'loamy': return localizations.soilLoamy;
      case 'red': return localizations.soilRed;
      case 'sandy': return localizations.soilSandy;
      default: return soil;
    }
  }

  String _getLocalizedPlantCondition(BuildContext context, String condition) {
    final localizations = AppLocalizations.of(context)!;
    switch (condition) {
      case 'healthy': return localizations.conditionHealthy;
      case 'slow growth': return localizations.conditionSlowGrowth;
      case 'yellow leaves': return localizations.conditionYellowLeaves;
      case 'pale leaves': return localizations.conditionPaleLeaves;
      case 'brown spots': return localizations.conditionBrownSpots;
      case 'weak stem': return localizations.conditionWeakStem;
      default: return condition;
    }
  }

  String _getLocalizedIrrigationType(BuildContext context, String type) {
    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case 'canal': return localizations.irrigationCanal;
      case 'borewell': return localizations.irrigationBorewell;
      case 'drip': return localizations.irrigationDrip;
      case 'sprinkler': return localizations.irrigationSprinkler;
      case 'rain': return localizations.irrigationRain;
      default: return type;
    }
  }

  String _getLocalizedSoilMoisture(BuildContext context, String moisture) {
    final localizations = AppLocalizations.of(context)!;
    switch (moisture) {
      case 'low': return localizations.moistureLow;
      case 'medium': return localizations.moistureMedium;
      case 'high': return localizations.moistureHigh;
      default: return moisture;
    }
  }

  // Shared UI Components
  Widget _buildHeaderCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PurpleTheme.primaryLight, PurpleTheme.accent],
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
              color: PurpleTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF4A5B49))),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: PurpleTheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                child: Text(getDisplayName(item).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String valueText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: PurpleTheme.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E2B))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: PurpleTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                valueText,
                style: TextStyle(fontWeight: FontWeight.bold, color: PurpleTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: PurpleTheme.primary,
          inactiveColor: PurpleTheme.accent,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: multiline ? 14 : 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E2B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PurpleTheme.accent),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF4A5B49))),
    );
  }
}