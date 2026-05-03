// lib/screens/crops_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_header.dart';
import '../widgets/settings_menu.dart';
import '../api/api_service.dart';
import '../api/api_request.dart';
import '../api/api_response.dart';
import '../services/cache_manager.dart';
import '../l10n/app_localizations.dart';

// ==================== ENUMS (localized) ====================
enum GrowthStage {
  germination('germination'),
  vegetative('vegetative'),
  flowering('flowering'),
  fruiting('fruiting'),
  harvesting('harvesting');

  final String value;
  const GrowthStage(this.value);

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case germination:
        return l10n.germinationStage;
      case vegetative:
        return l10n.vegetativeStage;
      case flowering:
        return l10n.floweringStage;
      case fruiting:
        return l10n.fruitingStage;
      case harvesting:
        return l10n.harvestingStage;
    }
  }

  IconData get icon {
    switch (this) {
      case germination:
        return Icons.grass;
      case vegetative:
        return Icons.eco;
      case flowering:
        return Icons.local_florist;
      case fruiting:
        return Icons.apple;
      case harvesting:
        return Icons.agriculture;
    }
  }

  Color get color {
    switch (this) {
      case germination:
        return Colors.green.shade300;
      case vegetative:
        return Colors.green.shade500;
      case flowering:
        return Colors.orange.shade400;
      case fruiting:
        return Colors.deepOrange.shade400;
      case harvesting:
        return Colors.brown.shade400;
    }
  }

  static GrowthStage fromValue(String value) {
    return GrowthStage.values.firstWhere(
          (e) => e.value == value,
      orElse: () => GrowthStage.germination,
    );
  }
}

enum SoilType {
  black('black'),
  red('red'),
  sandy('sandy'),
  clay('clay'),
  loamy('loamy');

  final String value;
  const SoilType(this.value);

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case black:
        return l10n.blackSoil;
      case red:
        return l10n.redSoil;
      case sandy:
        return l10n.sandySoil;
      case clay:
        return l10n.claySoil;
      case loamy:
        return l10n.loamySoil;
    }
  }

  static SoilType fromValue(String value) {
    return SoilType.values.firstWhere(
          (e) => e.value == value,
      orElse: () => SoilType.loamy,
    );
  }
}

enum IrrigationType {
  drip('drip'),
  sprinkler('sprinkler'),
  canal('canal'),
  rainfed('rainfed'),
  manual('manual');

  final String value;
  const IrrigationType(this.value);

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case drip:
        return l10n.dripIrrigation;
      case sprinkler:
        return l10n.sprinklerSystem;
      case canal:
        return l10n.canalWater;
      case rainfed:
        return l10n.rainfed;
      case manual:
        return l10n.manual;
    }
  }

  static IrrigationType fromValue(String value) {
    return IrrigationType.values.firstWhere(
          (e) => e.value == value,
      orElse: () => IrrigationType.drip,
    );
  }
}

enum HealthStatus {
  healthy('healthy'),
  minorIssues('minorIssues'),
  majorIssues('majorIssues'),
  critical('critical');

  final String value;
  const HealthStatus(this.value);

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case healthy:
        return l10n.healthy;
      case minorIssues:
        return l10n.minorIssues;
      case majorIssues:
        return l10n.majorIssues;
      case critical:
        return l10n.critical;
    }
  }

  Color get color {
    switch (this) {
      case healthy:
        return Colors.green;
      case minorIssues:
        return Colors.orange;
      case majorIssues:
        return Colors.deepOrange;
      case critical:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case healthy:
        return Icons.check_circle;
      case minorIssues:
        return Icons.warning_amber;
      case majorIssues:
        return Icons.error_outline;
      case critical:
        return Icons.cancel;
    }
  }

  static HealthStatus fromValue(String value) {
    return HealthStatus.values.firstWhere(
          (e) => e.value == value,
      orElse: () => HealthStatus.healthy,
    );
  }
}

// ==================== CROP MODEL ====================
class Crop {
  final int id;
  final String name;
  final String? variety;
  final DateTime sowingDate;
  final double area;
  final SoilType soilType;
  final IrrigationType irrigationType;
  final String? location;
  final GrowthStage growthStage;
  final HealthStatus healthStatus;
  final String? lastFertilizer;

  Crop({
    required this.id,
    required this.name,
    this.variety,
    required this.sowingDate,
    required this.area,
    required this.soilType,
    required this.irrigationType,
    this.location,
    required this.growthStage,
    required this.healthStatus,
    this.lastFertilizer,
  });

  int get daysSinceSowing => DateTime.now().difference(sowingDate).inDays;
  String get formattedSowingDate =>
      DateFormat('dd MMM yyyy').format(sowingDate);

  factory Crop.fromApi(CropData data) {
    return Crop(
      id: data.id,
      name: data.name,
      variety: data.variety,
      sowingDate: DateTime.parse(data.sowingDate),
      area: data.area,
      soilType: SoilType.fromValue(data.soilType),
      irrigationType: IrrigationType.fromValue(data.irrigationType),
      location: data.location,
      growthStage: GrowthStage.fromValue(data.growthStage),
      healthStatus: HealthStatus.fromValue(data.healthStatus),
      lastFertilizer: data.lastFertilizer,
    );
  }
}

// ==================== SEARCH DELEGATE ====================
class CropSearchDelegate extends SearchDelegate<Crop?> {
  final List<Crop> crops;

  CropSearchDelegate(this.crops);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = crops.where((crop) =>
    crop.name.toLowerCase().contains(query.toLowerCase()) ||
        (crop.variety?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final crop = results[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: crop.growthStage.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(crop.growthStage.icon, color: crop.growthStage.color),
          ),
          title: Text(crop.name),
          subtitle: crop.variety != null
              ? Text(crop.variety!)
              : Text(DateFormat('dd MMM yyyy').format(crop.sowingDate)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: crop.healthStatus.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              crop.healthStatus.displayName(context),
              style: TextStyle(color: crop.healthStatus.color, fontSize: 12),
            ),
          ),
          onTap: () {
            close(context, crop);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = crops.where((crop) =>
    crop.name.toLowerCase().contains(query.toLowerCase()) ||
        (crop.variety?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final crop = suggestions[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: crop.growthStage.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(crop.growthStage.icon, color: crop.growthStage.color),
          ),
          title: Text(crop.name),
          subtitle: crop.variety != null
              ? Text(crop.variety!)
              : Text(DateFormat('dd MMM yyyy').format(crop.sowingDate)),
          onTap: () {
            query = crop.name;
            showResults(context);
          },
        );
      },
    );
  }
}

// ==================== MAIN CROPS SCREEN ====================
class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  final CacheManager _cache = CacheManager();
  final CropService _cropService = CropService();

  List<Crop> _userCrops = [];
  String? _selectedFilter; // null = All, otherwise crop name
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_cache.cachedCrops.isNotEmpty && _cache.cropsInitialized) {
      setState(() {
        _userCrops = List.from(_cache.cachedCrops);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _cropService.listCrops();
      if (response.status) {
        _userCrops = response.data.map((c) => Crop.fromApi(c)).toList();
        _cache.cachedCrops = List.from(_userCrops);
        _cache.cropsInitialized = true;
      } else {
        if (mounted) {
          setState(() {
            _error = AppLocalizations.of(context)!.failedToLoadCropsCS;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '${AppLocalizations.of(context)!.errorPrefix} $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateCache() {
    _cache.cachedCrops = List.from(_userCrops);
  }

  List<Crop> get _filteredCrops {
    if (_selectedFilter == null) return _userCrops;
    return _userCrops.where((c) => c.name == _selectedFilter).toList();
  }

  List<(String display, String? value)> get _filterOptions {
    final l10n = AppLocalizations.of(context)!;
    final uniqueCropNames = _userCrops.map((c) => c.name).toSet().toList();
    return [
      (l10n.all, null),
      ...uniqueCropNames.map((name) => (name, name)),
    ];
  }

  void _showSettingsMenu() => SettingsMenu.show(context);

  Future<void> _addNewCrop() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CropFormScreen()),
    );
    if (result != null && result is Crop) {
      setState(() {
        _userCrops.add(result);
        _updateCache();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .cropAddedSuccessfully(result.name))),
        );
      }
    }
  }

  void _refreshList() => setState(() {});

  void _onSearchPressed() async {
    final selectedCrop = await showSearch<Crop?>(
      context: context,
      delegate: CropSearchDelegate(_userCrops),
    );
    if (selectedCrop != null && mounted) {
      // Navigate to crop detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropDetailScreen(
            crop: selectedCrop,
            onCropUpdated: (updatedCrop) {
              final index = _userCrops.indexWhere((c) => c.id == updatedCrop.id);
              if (index != -1) {
                setState(() {
                  _userCrops[index] = updatedCrop;
                  _updateCache();
                });
              }
            },
            onCropDeleted: (cropId) {
              setState(() {
                _userCrops.removeWhere((c) => c.id == cropId);
                _updateCache();
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppHeader(
        showMenuButton: true,
        onMenuPressed: _showSettingsMenu,
        actionWidget: IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
          onPressed: _onSearchPressed,
          tooltip: l10n.searchCropsHint,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _userCrops.isEmpty
          ? _buildEmptyState(context)
          : Column(
        children: [
          // Filter Chips (horizontal scroll)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final (display, value) = _filterOptions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(display),
                    selected: _selectedFilter == value,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF4CAF50)
                        .withOpacity(0.2),
                  ),
                );
              },
            ),
          ),
          // Crop List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCrops.length,
              itemBuilder: (context, index) =>
                  _buildCropCard(context, _filteredCrops[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCrop,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noCropsAddedYet,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapAddFirstCrop,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, Crop crop) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropDetailScreen(
                crop: crop,
                onCropUpdated: (updatedCrop) {
                  final index =
                  _userCrops.indexWhere((c) => c.id == updatedCrop.id);
                  if (index != -1) {
                    setState(() {
                      _userCrops[index] = updatedCrop;
                      _updateCache();
                    });
                  }
                },
                onCropDeleted: (cropId) {
                  setState(() {
                    _userCrops.removeWhere((c) => c.id == cropId);
                    _updateCache();
                  });
                },
              ),
            ),
          );
          if (result == true) _refreshList();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: crop.growthStage.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(crop.growthStage.icon,
                        color: crop.growthStage.color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (crop.variety != null)
                          Text(
                            crop.variety!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: crop.healthStatus.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(crop.healthStatus.icon,
                            color: crop.healthStatus.color, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            crop.healthStatus.displayName(context),
                            style: TextStyle(
                                fontSize: 11,
                                color: crop.healthStatus.color,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(context, Icons.calendar_today,
                      l10n.daysCount(crop.daysSinceSowing)),
                  _buildInfoChip(
                      context, Icons.eco, crop.growthStage.displayName(context)),
                  _buildInfoChip(context, Icons.straighten,
                      l10n.acresCount(crop.area)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (crop.daysSinceSowing / 120).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor:
                AlwaysStoppedAnimation<Color>(crop.growthStage.color),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.germinationStage,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    l10n.harvest,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}

// ==================== CROP FORM (ADD / EDIT) ====================
class CropFormScreen extends StatefulWidget {
  final Crop? existingCrop;
  const CropFormScreen({super.key, this.existingCrop});

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late AddCropFormData _formData;
  final CropService _cropService = CropService();
  bool _isSubmitting = false;

  final List<String> _popularCrops = [
    'Bajra',
    'Chickpea',
    'Cotton',
    'Grapes',
    'Groundnut',
    'Jowar',
    'Maize',
    'Millet',
    'Onion',
    'Pomegranate',
    'Potato',
    'Rice',
    'Soybean',
    'Sugarcane',
    'Sunflower',
    'Tomato',
    'Tur',
    'Wheat'
  ];

  @override
  void initState() {
    super.initState();
    _initFormData();
  }

  void _initFormData() {
    if (widget.existingCrop != null) {
      final crop = widget.existingCrop!;
      _formData = AddCropFormData(
        name: crop.name,
        variety: crop.variety ?? '',
        sowingDate: crop.sowingDate,
        area: crop.area,
        soilType: crop.soilType,
        irrigationType: crop.irrigationType,
        location: crop.location ?? '',
        growthStage: crop.growthStage,
        healthStatus: crop.healthStatus,
        lastFertilizer: crop.lastFertilizer ?? '',
      );
    } else {
      _formData = AddCropFormData();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final isEditing = widget.existingCrop != null;
      if (isEditing) {
        final request = CropUpdateRequest(
          id: widget.existingCrop!.id,
          name: _formData.name,
          variety: _formData.variety.isEmpty ? null : _formData.variety,
          sowingDate:
          DateFormat('yyyy-MM-dd').format(_formData.sowingDate),
          area: _formData.area,
          soilType: _formData.soilType.value,
          irrigationType: _formData.irrigationType.value,
          location: _formData.location.isEmpty ? null : _formData.location,
          growthStage: _formData.growthStage.value,
          healthStatus: _formData.healthStatus.value,
          lastFertilizer:
          _formData.lastFertilizer.isEmpty ? null : _formData.lastFertilizer,
        );
        final response = await _cropService.updateCrop(request);
        if (response.status && response.data != null) {
          final updatedCrop = Crop.fromApi(response.data!);
          Navigator.pop(context, updatedCrop);
        } else {
          throw Exception('Update failed');
        }
      } else {
        final request = CropCreateRequest(
          name: _formData.name,
          variety: _formData.variety.isEmpty ? null : _formData.variety,
          sowingDate:
          DateFormat('yyyy-MM-dd').format(_formData.sowingDate),
          area: _formData.area,
          soilType: _formData.soilType.value,
          irrigationType: _formData.irrigationType.value,
          location: _formData.location.isEmpty ? null : _formData.location,
          growthStage: _formData.growthStage.value,
          healthStatus: _formData.healthStatus.value,
          lastFertilizer:
          _formData.lastFertilizer.isEmpty ? null : _formData.lastFertilizer,
        );
        final response = await _cropService.createCrop(request);
        if (response.status && response.data != null) {
          final newCrop = Crop.fromApi(response.data!);
          Navigator.pop(context, newCrop);
        } else {
          throw Exception('Creation failed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.errorPrefix} $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingCrop != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? l10n.editCrop(widget.existingCrop!.name)
            : l10n.addNewCrop),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader(
                context, Icons.info_outline, l10n.basicInformation),
            const SizedBox(height: 16),
            _buildStyledDropdownFormField(
              context,
              label: l10n.cropNameLabel,
              hint: l10n.selectCropTypeHint,
              required: true,
              value: _formData.name.isEmpty ? null : _formData.name,
              items: _popularCrops,
              onChanged: (val) => setState(() => _formData.name = val ?? ''),
              validator: (val) =>
              val == null || val.isEmpty ? l10n.pleaseSelectCrop : null,
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              context,
              label: l10n.varietyLabel,
              hint: l10n.varietyHint,
              prefixIcon: Icons.dashboard,
              initialValue: _formData.variety,
              onChanged: (val) => _formData.variety = val,
              isOptional: true,
            ),
            const SizedBox(height: 16),
            _buildStyledDatePicker(
              context,
              label: l10n.sowingDateLabel,
              value: _formData.sowingDate,
              prefixIcon: Icons.calendar_today,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _formData.sowingDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _formData.sowingDate = date);
              },
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              context,
              label: l10n.fieldAreaLabel,
              hint: l10n.enterAreaHint,
              prefixIcon: Icons.straighten,
              suffixText: l10n.acresUnit,
              keyboardType: TextInputType.number,
              required: true,
              initialValue: _formData.area.toString(),
              onChanged: (val) =>
              _formData.area = double.tryParse(val) ?? 0,
              validator: (val) {
                if (val == null || val.isEmpty)
                  return l10n.pleaseEnterArea;
                final area = double.tryParse(val);
                if (area == null || area <= 0)
                  return l10n.enterValidPositiveNumber;
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildSectionHeader(
                context, Icons.landscape, l10n.farmConditions),
            const SizedBox(height: 16),
            _buildStyledDropdownFormField(
              context,
              label: l10n.soilTypeLabel,
              hint: l10n.selectSoilTypeHint,
              value: _formData.soilType.displayName(context),
              items: SoilType.values.map((e) => e.displayName(context)).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _formData.soilType = SoilType.values.firstWhere(
                            (e) => e.displayName(context) == val);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildStyledDropdownFormField(
              context,
              label: l10n.irrigationTypeLabel,
              hint: l10n.selectIrrigationHint,
              value: _formData.irrigationType.displayName(context),
              items: IrrigationType.values
                  .map((e) => e.displayName(context))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _formData.irrigationType = IrrigationType.values.firstWhere(
                            (e) => e.displayName(context) == val);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              context,
              label: l10n.locationLabel,
              hint: l10n.locationHint,
              prefixIcon: Icons.location_on,
              initialValue: _formData.location,
              onChanged: (val) => _formData.location = val,
              isOptional: true,
            ),
            const SizedBox(height: 28),
            _buildSectionHeader(
                context, Icons.sensors, l10n.currentCropStatus),
            const SizedBox(height: 16),
            _buildStyledDropdownFormField(
              context,
              label: l10n.growthStageLabel,
              hint: l10n.selectGrowthStageHint,
              value: _formData.growthStage.displayName(context),
              items:
              GrowthStage.values.map((e) => e.displayName(context)).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _formData.growthStage = GrowthStage.values.firstWhere(
                            (e) => e.displayName(context) == val);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildStyledDropdownFormField(
              context,
              label: l10n.healthStatusLabel,
              hint: l10n.selectHealthStatusHint,
              value: _formData.healthStatus.displayName(context),
              items: HealthStatus.values
                  .map((e) => e.displayName(context))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _formData.healthStatus = HealthStatus.values.firstWhere(
                            (e) => e.displayName(context) == val);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildStyledTextField(
              context,
              label: l10n.lastFertilizerLabel,
              hint: l10n.lastFertilizerHint,
              prefixIcon: Icons.science,
              initialValue: _formData.lastFertilizer,
              onChanged: (val) => _formData.lastFertilizer = val,
              isOptional: true,
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(context, isEditing, _isSubmitting),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) =>
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32)),
          ),
        ],
      );

  Widget _buildStyledTextField(
      BuildContext context, {
        required String label,
        required String hint,
        IconData? prefixIcon,
        String? suffixText,
        TextInputType? keyboardType,
        required Function(String) onChanged,
        String? initialValue,
        String? Function(String?)? validator,
        bool required = false,
        bool isOptional = false,
      }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)),
            ),
            if (required) const SizedBox(width: 4),
            if (required)
              const Text('*',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4)),
                child: Text(
                  l10n.optional,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF4CAF50), size: 20)
                : null,
            suffixText: suffixText,
            suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildStyledDropdownFormField(
      BuildContext context, {
        required String label,
        required String hint,
        required List<String> items,
        required Function(String?) onChanged,
        required dynamic value,
        bool required = false,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)),
            ),
            if (required) const SizedBox(width: 4),
            if (required)
              const Text('*',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.arrow_drop_down_circle,
                  color: Color(0xFF4CAF50), size: 20),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: Color(0xFF4CAF50), width: 2)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: onChanged,
            validator: validator,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            elevation: 4,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDatePicker(
      BuildContext context, {
        required String label,
        required DateTime value,
        IconData? prefixIcon,
        required VoidCallback onTap,
        bool required = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)),
            ),
            if (required) const SizedBox(width: 4),
            if (required)
              const Text('*',
                  style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(prefixIcon ?? Icons.calendar_today,
                    color: const Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(DateFormat('dd MMM yyyy').format(value),
                        style: const TextStyle(fontSize: 14))),
                Icon(Icons.edit_calendar, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, bool isEditing, bool isSubmitting) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isSubmitting
            ? const SizedBox(
            width: 24,
            height: 24,
            child:
            CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEditing ? Icons.edit : Icons.add_circle_outline,
                size: 20),
            const SizedBox(width: 8),
            Text(
              isEditing ? l10n.updateCropButton : l10n.addCropButton,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CROP DETAIL SCREEN ====================
class CropDetailScreen extends StatelessWidget {
  final Crop crop;
  final Function(Crop) onCropUpdated;
  final Function(int) onCropDeleted;
  final CropService _cropService = CropService();

  CropDetailScreen(
      {super.key,
        required this.crop,
        required this.onCropUpdated,
        required this.onCropDeleted});

  Future<void> _editCrop(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CropFormScreen(existingCrop: crop)));
    if (result != null && result is Crop) {
      onCropUpdated(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!
                .cropUpdatedSuccessfully(result.name))));
      }
    }
  }

  Future<void> _deleteCrop(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCropTitle),
        content: Text(l10n.deleteCropConfirmation(crop.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final success = await _cropService.deleteCrop(crop.id);
        if (success) {
          onCropDeleted(crop.id);
          if (context.mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.cropDeletedSuccessfully(crop.name))));
          }
        } else {
          throw Exception('Delete failed');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${l10n.errorPrefix} $e'),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editCrop(context),
              tooltip: l10n.editCropTooltip),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCrop(context),
              tooltip: l10n.deleteCropTooltip),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: crop.healthStatus.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: crop.healthStatus.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: crop.growthStage.color.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: Icon(crop.growthStage.icon,
                          size: 32, color: crop.growthStage.color)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (crop.variety != null)
                          Text(
                            crop.variety!,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                l10n.sownWithDateAndDays(
                                    crop.formattedSowingDate,
                                    crop.daysSinceSowing),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: crop.healthStatus.color,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(crop.healthStatus.icon,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          crop.healthStatus.displayName(context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.fieldInformation,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildDetailRow(context, Icons.straighten,
                      l10n.fieldAreaLabelDetail, l10n.acresCount(crop.area)),
                  _buildDivider(),
                  _buildDetailRow(context, Icons.agriculture,
                      l10n.soilTypeLabelDetail, crop.soilType.displayName(context)),
                  _buildDivider(),
                  _buildDetailRow(context, Icons.water_drop,
                      l10n.irrigationTypeLabelDetail,
                      crop.irrigationType.displayName(context)),
                  if (crop.location != null) ...[
                    _buildDivider(),
                    _buildDetailRow(context, Icons.location_on,
                        l10n.locationLabelDetail, crop.location!)
                  ],
                  if (crop.lastFertilizer != null) ...[
                    _buildDivider(),
                    _buildDetailRow(context, Icons.science,
                        l10n.lastFertilizerLabelDetail, crop.lastFertilizer!)
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.growthInformation,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildDetailRow(context, Icons.eco,
                      l10n.currentGrowthStageLabel,
                      crop.growthStage.displayName(context)),
                  _buildDivider(),
                  _buildDetailRow(context, Icons.calendar_today,
                      l10n.daysSinceSowingLabel, l10n.daysCount(crop.daysSinceSowing)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.growthTimeline,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                children: [
                  _buildTimelineStep(
                      context, l10n.germinationStage, 0, crop.daysSinceSowing),
                  _buildTimelineStep(context, l10n.vegetativeStage, 15,
                      crop.daysSinceSowing),
                  _buildTimelineStep(context, l10n.floweringStage, 45,
                      crop.daysSinceSowing),
                  _buildTimelineStep(context, l10n.fruitingStage, 70,
                      crop.daysSinceSowing),
                  _buildTimelineStep(context, l10n.harvestingStage, 100,
                      crop.daysSinceSowing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label,
      String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 16),
            Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                )),
            const SizedBox(width: 8),
            Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
      );

  Widget _buildDivider() =>
      Divider(height: 1, thickness: 1, color: Colors.grey[200]);

  Widget _buildTimelineStep(
      BuildContext context, String stage, int expectedDay, int currentDay) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = currentDay >= expectedDay;
    final isCurrent = currentDay >= expectedDay &&
        (stage == l10n.germinationStage || currentDay < (expectedDay + 30));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey[300]),
              child: Icon(isCompleted ? Icons.check : Icons.access_time,
                  size: 18,
                  color: isCompleted ? Colors.white : Colors.grey[600])),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stage,
              style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.green : Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.dayWithNumber(expectedDay),
            style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Colors.green : Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ==================== FORM DATA MODEL ====================
class AddCropFormData {
  String name;
  String variety;
  DateTime sowingDate;
  double area;
  SoilType soilType;
  IrrigationType irrigationType;
  String location;
  GrowthStage growthStage;
  HealthStatus healthStatus;
  String lastFertilizer;

  AddCropFormData({
    this.name = '',
    this.variety = '',
    DateTime? sowingDate,
    this.area = 1.0,
    this.soilType = SoilType.loamy,
    this.irrigationType = IrrigationType.drip,
    this.location = '',
    this.growthStage = GrowthStage.germination,
    this.healthStatus = HealthStatus.healthy,
    this.lastFertilizer = '',
  }) : sowingDate = sowingDate ?? DateTime.now();
}