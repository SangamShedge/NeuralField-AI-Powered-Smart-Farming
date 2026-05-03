import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/api_service.dart';
import '../api/api_request.dart';
import '../api/api_response.dart';
import '../l10n/app_localizations.dart';

// Orange Theme Constants
class OrangeTheme {
  static const Color primary = Color(0xFFFF9800);
  static const Color primaryLight = Color(0xFFFFF3E0);
  static const Color primaryDark = Color(0xFFF57C00);
  static const Color accent = Color(0xFFFFE0B2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C3E2B);
  static const Color textLight = Color(0xFF4A5B49);
  static const Color gradientStart = Color(0xFFFFF3E0);
  static const Color gradientEnd = Color(0xFFFFE0B2);
}

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  State<FertilizerCalculatorScreen> createState() =>
      _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState
    extends State<FertilizerCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final FertilizerApiService _apiService = FertilizerApiService();

  // All values are in ACRES (backend's expected unit)
  double _areaAcres = 2.0;
  double _targetYieldTonsPerAcre = 5.0;
  double _soilNitrogenKgPerAcre = 250.0;
  double _soilPhosphorusKgPerAcre = 20.0;
  double _soilPotassiumKgPerAcre = 150.0;

  // Crop list – exactly matching backend JSON
  final List<String> _crops = [
    'Rice', 'Wheat', 'Maize', 'Jowar', 'Bajra', 'Millet',
    'Soybean', 'Groundnut', 'Tur', 'Chickpea', 'Cotton', 'Sugarcane',
    'Sunflower', 'Onion', 'Tomato', 'Potato', 'Pomegranate', 'Grapes'
  ];

  String _selectedCrop = 'Rice';

  final Map<String, Map<String, double>> _fertilizerNPK = {
    'Urea': {'N': 46, 'P': 0, 'K': 0},
    'DAP': {'N': 18, 'P': 46, 'K': 0},
    'MOP': {'N': 0, 'P': 0, 'K': 60},
    'SSP': {'N': 0, 'P': 16, 'K': 0},
    'NPK 10-26-26': {'N': 10, 'P': 26, 'K': 26},
    'NPK 12-32-16': {'N': 12, 'P': 32, 'K': 16},
    'NPK 15-15-15': {'N': 15, 'P': 15, 'K': 15},
    'NPK 20-20-20': {'N': 20, 'P': 20, 'K': 20},
  };

  String _selectedNitrogenFertilizer = 'Urea';
  String _selectedPhosphorusFertilizer = 'DAP';
  String _selectedPotassiumFertilizer = 'MOP';

  bool _isCalculated = false;
  bool _isLoading = false;
  String? _errorMessage;
  NPKCalculatorResponse? _apiResponse;

  // Controllers for numeric input fields
  late TextEditingController _areaController;
  late TextEditingController _yieldController;
  final FocusNode _areaFocus = FocusNode();
  final FocusNode _yieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController();
    _yieldController = TextEditingController();
    _updateControllersFromState();
  }

  @override
  void dispose() {
    _areaController.dispose();
    _yieldController.dispose();
    _areaFocus.dispose();
    _yieldFocus.dispose();
    super.dispose();
  }

  void _updateControllersFromState() {
    _areaController.text = _areaAcres.toStringAsFixed(2);
    _yieldController.text = _targetYieldTonsPerAcre.toStringAsFixed(2);
  }

  // Update methods (called from onChanged) – no controller text update here!
  void _updateArea(double newArea) {
    setState(() {
      _areaAcres = newArea;
    });
  }

  void _updateTargetYield(double newYield) {
    setState(() {
      _targetYieldTonsPerAcre = newYield;
    });
  }

  void _updateSoilNitrogen(double newValue) {
    setState(() => _soilNitrogenKgPerAcre = newValue);
  }

  void _updateSoilPhosphorus(double newValue) {
    setState(() => _soilPhosphorusKgPerAcre = newValue);
  }

  void _updateSoilPotassium(double newValue) {
    setState(() => _soilPotassiumKgPerAcre = newValue);
  }

  // Increment/decrement for soil values
  void _incrementSoilN() {
    double newVal = _soilNitrogenKgPerAcre + 1;
    if (newVal <= 500) _updateSoilNitrogen(newVal);
  }

  void _decrementSoilN() {
    double newVal = _soilNitrogenKgPerAcre - 1;
    if (newVal >= 0) _updateSoilNitrogen(newVal);
  }

  void _incrementSoilP() {
    double newVal = _soilPhosphorusKgPerAcre + 1;
    if (newVal <= 200) _updateSoilPhosphorus(newVal);
  }

  void _decrementSoilP() {
    double newVal = _soilPhosphorusKgPerAcre - 1;
    if (newVal >= 0) _updateSoilPhosphorus(newVal);
  }

  void _incrementSoilK() {
    double newVal = _soilPotassiumKgPerAcre + 1;
    if (newVal <= 400) _updateSoilPotassium(newVal);
  }

  void _decrementSoilK() {
    double newVal = _soilPotassiumKgPerAcre - 1;
    if (newVal >= 0) _updateSoilPotassium(newVal);
  }

  Future<void> _calculateWithApi() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save(); // ensure onSaved is called

    // print('=== API Request Values ===');
    // print('area (acres): $_areaAcres');
    // print('targetYield (tons/acre): $_targetYieldTonsPerAcre');
    // print('soilN (kg/acre): $_soilNitrogenKgPerAcre');
    // print('soilP (kg/acre): $_soilPhosphorusKgPerAcre');
    // print('soilK (kg/acre): $_soilPotassiumKgPerAcre');
    // print('crop: $_selectedCrop');
    // print('N source: $_selectedNitrogenFertilizer');
    // print('P source: $_selectedPhosphorusFertilizer');
    // print('K source: $_selectedPotassiumFertilizer');
    // print('==========================');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = NPKCalculatorRequest(
        area: _areaAcres,
        targetYield: _targetYieldTonsPerAcre,
        soilN: _soilNitrogenKgPerAcre,
        soilP: _soilPhosphorusKgPerAcre,
        soilK: _soilPotassiumKgPerAcre,
        crop: _selectedCrop,
        nitrogenSource: _selectedNitrogenFertilizer,
        phosphorusSource: _selectedPhosphorusFertilizer,
        potassiumSource: _selectedPotassiumFertilizer,
      );

      final response = await _apiService.calculateNPK(request);
      setState(() {
        _apiResponse = response;
        _isCalculated = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _resetCalculator() {
    setState(() {
      _isCalculated = false;
      _apiResponse = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: Text(t.fertilizerCalculator),
        backgroundColor: const Color(0xFFF5F7F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrangeTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isCalculated)
            IconButton(
              icon: const Icon(Icons.refresh, color: OrangeTheme.primary),
              onPressed: _resetCalculator,
              tooltip: t.newCalculationTooltip,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('${t.errorPrefix} $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetCalculator,
              style: ElevatedButton.styleFrom(
                backgroundColor: OrangeTheme.primary,
              ),
              child: Text(t.tryAgain),
            ),
          ],
        ),
      )
          : _isCalculated && _apiResponse != null
          ? _buildResultsScreen(context)
          : _buildInputForm(context),
    );
  }

  Widget _buildInputForm(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(
              icon: Icons.calculate,
              title: t.smartNpkCalculator,
              subtitle: t.calculatePreciseFertilizerRequirementsSubtitle,
            ),
            const SizedBox(height: 20),
            // Basic Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildDropdownField(
                    label: t.cropTypeLabel,
                    icon: Icons.agriculture,
                    value: _selectedCrop,
                    items: _crops,
                    onChanged: (value) =>
                        setState(() => _selectedCrop = value!),
                  ),
                  const SizedBox(height: 20),
                  // Field Area input
                  _buildNumericInputField(
                    label: t.fieldAreaLabel,
                    icon: Icons.crop_free,
                    controller: _areaController,
                    focusNode: _areaFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final num = double.tryParse(value);
                      if (num == null) return 'Invalid number';
                      if (num <= 0) return 'Must be > 0';
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) _updateArea(double.parse(value));
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final newVal = double.tryParse(value);
                        if (newVal != null && newVal > 0) _updateArea(newVal);
                      }
                    },
                    unit: t.unitAcres,
                  ),
                  const SizedBox(height: 20),
                  // Target Yield input
                  _buildNumericInputField(
                    label: t.targetYieldLabel,
                    icon: Icons.trending_up,
                    controller: _yieldController,
                    focusNode: _yieldFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final num = double.tryParse(value);
                      if (num == null) return 'Invalid number';
                      if (num <= 0) return 'Must be > 0';
                      return null;
                    },
                    onSaved: (value) {
                      if (value != null) _updateTargetYield(double.parse(value));
                    },
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final newVal = double.tryParse(value);
                        if (newVal != null && newVal > 0)
                          _updateTargetYield(newVal);
                      }
                    },
                    unit: 'tons/${t.unitAcres}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Soil Test Results Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: OrangeTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.soilTestResultsKgPerUnit(t.unitAcres),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedSoilInputCard(
                    label: t.nitrogenN,
                    icon: Icons.eco,
                    value: _soilNitrogenKgPerAcre,
                    min: 0,
                    max: 500,
                    color: const Color(0xFF4CAF50),
                    onChanged: _updateSoilNitrogen,
                    onIncrement: _incrementSoilN,
                    onDecrement: _decrementSoilN,
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedSoilInputCard(
                    label: t.phosphorusP,
                    icon: Icons.bubble_chart,
                    value: _soilPhosphorusKgPerAcre,
                    min: 0,
                    max: 200,
                    color: const Color(0xFF2196F3),
                    onChanged: _updateSoilPhosphorus,
                    onIncrement: _incrementSoilP,
                    onDecrement: _decrementSoilP,
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedSoilInputCard(
                    label: t.potassiumK,
                    icon: Icons.water_drop,
                    value: _soilPotassiumKgPerAcre,
                    min: 0,
                    max: 400,
                    color: OrangeTheme.primary,
                    onChanged: _updateSoilPotassium,
                    onIncrement: _incrementSoilK,
                    onDecrement: _decrementSoilK,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Fertilizer Selection Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory, color: OrangeTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        t.fertilizerSelection,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFertilizerDropdown(
                    label: t.nitrogenSource,
                    value: _selectedNitrogenFertilizer,
                    onChanged: (value) =>
                        setState(() => _selectedNitrogenFertilizer = value!),
                    filterType: 'N',
                  ),
                  const SizedBox(height: 12),
                  _buildFertilizerDropdown(
                    label: t.phosphorusSource,
                    value: _selectedPhosphorusFertilizer,
                    onChanged: (value) =>
                        setState(() => _selectedPhosphorusFertilizer = value!),
                    filterType: 'P',
                  ),
                  const SizedBox(height: 12),
                  _buildFertilizerDropdown(
                    label: t.potassiumSource,
                    value: _selectedPotassiumFertilizer,
                    onChanged: (value) =>
                        setState(() => _selectedPotassiumFertilizer = value!),
                    filterType: 'K',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _calculateWithApi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrangeTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  t.calculateFertilizerRequirementsButton,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context) {
    // (unchanged – same as your previous version)
    final t = AppLocalizations.of(context)!;
    final data = _apiResponse!.data;
    final req = data.required;
    final soil = data.available;
    final apply = data.toApply;
    final fert = data.fertilizers;
    final eff = data.efficiencyPercent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NPK Summary Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [OrangeTheme.primary, OrangeTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🧪', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.npkRequirementSummary,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNPKCircle('N', req['N']!.toStringAsFixed(1),
                          const Color(0xFF4CAF50)),
                      _buildNPKCircle('P', req['P']!.toStringAsFixed(1),
                          const Color(0xFF2196F3)),
                      _buildNPKCircle('K', req['K']!.toStringAsFixed(1),
                          OrangeTheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // NPK Analysis Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: OrangeTheme.primary),
                    const SizedBox(width: 8),
                    Text(t.npkAnalysisKg,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(),
                _buildAnalysisRow(
                    t.npkRequired, req['N']!, req['P']!, req['K']!),
                const SizedBox(height: 12),
                _buildAnalysisRow(t.soilAvailable, soil['N']!, soil['P']!,
                    soil['K']!),
                const SizedBox(height: 12),
                _buildAnalysisRow(t.toApply, apply['N']!, apply['P']!,
                    apply['K']!, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Fertilizer Recommendation Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: OrangeTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: OrangeTheme.accent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.agriculture, color: OrangeTheme.primary),
                    const SizedBox(width: 8),
                    Text(t.fertilizerRecommendationTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(),
                _buildFertilizerRow(
                  t.nitrogenN,
                  fert['nitrogen']!.name,
                  fert['nitrogen']!.quantityKg.toStringAsFixed(1),
                  'kg',
                  eff['N']!.toStringAsFixed(0),
                  const Color(0xFF4CAF50),
                  context,
                ),
                const SizedBox(height: 16),
                _buildFertilizerRow(
                  t.phosphorusP,
                  fert['phosphorus']!.name,
                  fert['phosphorus']!.quantityKg.toStringAsFixed(1),
                  'kg',
                  eff['P']!.toStringAsFixed(0),
                  const Color(0xFF2196F3),
                  context,
                ),
                const SizedBox(height: 16),
                _buildFertilizerRow(
                  t.potassiumK,
                  fert['potassium']!.name,
                  fert['potassium']!.quantityKg.toStringAsFixed(1),
                  'kg',
                  eff['K']!.toStringAsFixed(0),
                  OrangeTheme.primary,
                  context,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Application Instructions Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text('Application Instructions',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionTile(t.timingInstructionTitle,
                    t.applyBeforeSowingInstruction),
                _buildInstructionTile(t.methodInstructionTitle,
                    t.broadcastEvenlyInstruction),
                _buildInstructionTile(t.irrigationInstructionTitle,
                    t.irrigateImmediatelyInstruction),
                _buildInstructionTile(t.cautionInstructionTitle,
                    t.avoidOverapplicationInstruction),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetCalculator,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(t.newCalculationButtonLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OrangeTheme.primary,
                    side: BorderSide(color: OrangeTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.calculationSavedSnackbar),
                        backgroundColor: OrangeTheme.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_alt, size: 18),
                  label: Text(t.saveButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrangeTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------- Helper Widgets -------------------
  Widget _buildHeaderCard(
      {required IconData icon,
        required String title,
        required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [OrangeTheme.gradientStart, OrangeTheme.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OrangeTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: OrangeTheme.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      {required String label,
        required IconData icon,
        required String value,
        required List<String> items,
        required Function(String?) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: OrangeTheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Fixed numeric input field – no unwanted selection behaviour
  Widget _buildNumericInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    required void Function(String) onChanged,
    required String unit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: OrangeTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                // Allow only one decimal point
                if (newValue.text.contains('.') &&
                    newValue.text.indexOf('.') != newValue.text.lastIndexOf('.')) {
                  return oldValue;
                }
                return newValue;
              }),
            ],
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: TextStyle(color: OrangeTheme.textLight),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: OrangeTheme.primaryLight,
            ),
            validator: validator,
            onSaved: onSaved,
            onChanged: onChanged,
            onEditingComplete: () {
              // Format the value to 2 decimals when editing is done
              String currentText = controller.text;
              if (currentText.isNotEmpty) {
                double? val = double.tryParse(currentText);
                if (val != null) {
                  String formatted = val.toStringAsFixed(2);
                  if (formatted != currentText) {
                    controller.text = formatted;
                    onChanged(formatted); // notify parent of formatted value
                  }
                }
              }
              focusNode.unfocus();
            },
          ),
        ),
      ],
    );
  }

  // Enhanced soil input card with +/- buttons
  Widget _buildEnhancedSoilInputCard({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required Color color,
    required Function(double) onChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            // Minus button
            GestureDetector(
              onTap: onDecrement,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Value display
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toInt()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Plus button
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: 100,
          activeColor: color,
          inactiveColor: color.withOpacity(0.2),
          onChanged: (newVal) {
            onChanged(newVal);
          },
        ),
      ],
    );
  }

  Widget _buildFertilizerDropdown(
      {required String label,
        required String value,
        required Function(String?) onChanged,
        required String filterType}) {
    final fertilizers = _fertilizerNPK.keys.where((key) {
      if (filterType == 'N') return _fertilizerNPK[key]!['N']! > 0;
      if (filterType == 'P') return _fertilizerNPK[key]!['P']! > 0;
      return _fertilizerNPK[key]!['K']! > 0;
    }).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: fertilizers.map((item) {
              final npk = _fertilizerNPK[item]!;
              return DropdownMenuItem(
                value: item,
                child: Text(
                    '$item (${npk['N']!.toInt()}-${npk['P']!.toInt()}-${npk['K']!.toInt()})'),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNPKCircle(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: color.withOpacity(0.2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Flexible(
                  child: Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, double n, double p, double k,
      {bool isBold = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
        ),
        Expanded(
            child: Text(n.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF4CAF50)))),
        Expanded(
            child: Text(p.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF2196F3)))),
        Expanded(
            child: Text(k.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(color: OrangeTheme.primary))),
      ],
    );
  }

  Widget _buildFertilizerRow(String nutrient, String name, String quantity,
      String unit, String efficiency, Color color, BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(nutrient.substring(0, 1),
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${t.efficiencyLabel} $efficiency%',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$quantity $unit',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(subtitle)),
        ],
      ),
    );
  }
}