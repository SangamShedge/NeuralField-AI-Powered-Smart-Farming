import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../api/api_service.dart';
import '../../api/api_response.dart';
import '../../api/api_url.dart';
import '../../providers/locale_provider.dart';

class CropInfoScreen extends StatefulWidget {
  const CropInfoScreen({super.key});

  @override
  State<CropInfoScreen> createState() => _CropInfoScreenState();
}

class _CropInfoScreenState extends State<CropInfoScreen> {
  String _searchQuery = '';
  String _selectedSeason = 'All';
  List<CropInfo> _allCrops = [];
  List<CropInfo> _filteredCrops = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  final CropEncyclopediaService _cropService = CropEncyclopediaService();

  // Track the currently selected language to detect changes
  String _currentLang = 'en';

  @override
  void initState() {
    super.initState();
    // Initial fetch will happen in didChangeDependencies after locale is read
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the current locale from provider
    final localeProvider = Provider.of<LocaleProvider>(context);
    final newLang = localeProvider.locale.languageCode;

    // If language changed, or first load (crops list empty), fetch crops
    if (_currentLang != newLang || _allCrops.isEmpty) {
      _currentLang = newLang;
      _fetchCropsWithLanguage();
    }
  }

  Future<void> _fetchCropsWithLanguage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pass the current language to the service
      final response = await _cropService.getAllCrops(language: _currentLang);

      if (response.isSuccess && response.data.isNotEmpty) {
        setState(() {
          _allCrops = response.data;
          _filteredCrops = response.data;
          _isLoading = false;
        });
      } else {
        final localizations = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = localizations.noCropsFound;
          _isLoading = false;
        });
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = '${localizations.failedToLoadCrops} $e';
        _isLoading = false;
      });
    }
  }

  void _updateCrops() {
    setState(() {
      _filteredCrops = _cropService.getCropsBySeason(_allCrops, _selectedSeason);
      if (_searchQuery.isNotEmpty) {
        _filteredCrops = _cropService.searchCrops(_filteredCrops, _searchQuery);
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _updateCrops();
      }
    });
  }

  @override
  void dispose() {
    _cropService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: localizations.searchCropsHint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _updateCrops();
            });
          },
        )
            : Text(localizations.cropEncyclopediaTitle),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearch,
            ),
          if (_isSearching)
            TextButton(
              onPressed: _toggleSearch,
              child: Text(localizations.cancel, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.loadingCrops,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchCropsWithLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSeasonChip(localizations.seasonAll),
                const SizedBox(width: 8),
                _buildSeasonChip(localizations.seasonKharif),
                const SizedBox(width: 8),
                _buildSeasonChip(localizations.seasonRabi),
                const SizedBox(width: 8),
                _buildSeasonChip(localizations.seasonZaid),
              ],
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _updateCrops();
                    if (_isSearching) {
                      _isSearching = false;
                    }
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${localizations.clearSearchPrefix} "$_searchQuery"',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: _filteredCrops.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? localizations.noCropsMatchSearch
                      : localizations.noCropsFound,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    localizations.tryDifferentSearchTerm,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredCrops.length,
            itemBuilder: (context, index) {
              return _buildCropCard(_filteredCrops[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonChip(String season) {
    final isSelected = _selectedSeason == season;
    final localizations = AppLocalizations.of(context)!;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeasonIcon(season),
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 4),
          Text(season),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSeason = season;
          _updateCrops();
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF4CAF50),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
        ),
      ),
    );
  }

  IconData _getSeasonIcon(String season) {
    final seasonLower = season.toLowerCase();
    if (seasonLower.contains('kharif')) {
      return Icons.grass;
    } else if (seasonLower.contains('rabi')) {
      return Icons.ac_unit;
    } else if (seasonLower.contains('zaid')) {
      return Icons.wb_sunny;
    } else {
      return Icons.category;
    }
  }

  // Updated card with image (like pest/disease list)
  Widget _buildCropCard(CropInfo crop) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropDetailInfoScreen(crop: crop),
            ),
          );
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
                  // Image container (50x50) with fallback icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildCropImage(crop),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          crop.scientificName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      crop.growingSeason.split(' ')[0],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.calendar_today, '${crop.growingDays} ${localizations.daysLabel}', Colors.orange),
                  _buildInfoChip(Icons.water_drop, crop.waterRequirement.split(' ')[0], Colors.blue),
                  _buildInfoChip(Icons.thermostat, crop.temperatureRange, Colors.red),
                  _buildInfoChip(Icons.agriculture, crop.getFormattedYield(), Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                crop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: crop image with fallback to icon
  Widget _buildCropImage(CropInfo crop) {
    final imageUrl = crop.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(_getCropIcon(crop.name), color: const Color(0xFF4CAF50), size: 30);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(_getCropIcon(crop.name), color: const Color(0xFF4CAF50), size: 30),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return Icons.grass;
      case 'wheat':
        return Icons.eco;
      case 'maize':
        return Icons.agriculture;
      case 'tomato':
        return Icons.apple;
      case 'potato':
        return Icons.circle;
      case 'onion':
        return Icons.layers;
      case 'cotton':
        return Icons.spa;
      case 'soybean':
        return Icons.eco;
      default:
        return Icons.eco;
    }
  }
}

// Detailed Crop Info Screen (with improved image styling)
class CropDetailInfoScreen extends StatefulWidget {
  final CropInfo crop;

  const CropDetailInfoScreen({super.key, required this.crop});

  @override
  State<CropDetailInfoScreen> createState() => _CropDetailInfoScreenState();
}

class _CropDetailInfoScreenState extends State<CropDetailInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crop.name),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(localizations.detailDescriptionTitle, content: widget.crop.description),
                  const SizedBox(height: 24),
                  _buildSection(localizations.detailGrowingInfoTitle, children: _buildGrowingInfo()),
                  const SizedBox(height: 24),
                  _buildSection(localizations.detailSowingHarvestingTitle, children: _buildSowingHarvestingInfo()),
                  const SizedBox(height: 24),
                  _buildSection(localizations.detailCommonVarietiesTitle, children: [_buildVarietiesWidget()]),
                  const SizedBox(height: 24),
                  _buildSection(localizations.detailHealthBenefitsTitle, children: [_buildBenefitsWidget()]),
                  const SizedBox(height: 24),
                  _buildSection(localizations.detailCompanionCropsTitle, children: [_buildCompanionCropsWidget()]),
                  const SizedBox(height: 24),
                  _buildSection(localizations.detailAvoidCropsTitle, children: [_buildAvoidCropsWidget()]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final imageUrl = widget.crop.imageUrl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          ClipOval(
            child: Container(
              width: 120,
              height: 120,
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              child: _buildImage(imageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.crop.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.crop.scientificName,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.crop.family,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(
        _getCropIcon(widget.crop.name),
        color: const Color(0xFF4CAF50),
        size: 60,
      );
    }
    return Image.network(
      imageUrl,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(
        _getCropIcon(widget.crop.name),
        color: const Color(0xFF4CAF50),
        size: 60,
      ),
    );
  }

  List<Widget> _buildGrowingInfo() {
    final localizations = AppLocalizations.of(context)!;
    return [
      _buildDetailRow(localizations.detailFamily, widget.crop.family),
      _buildDetailRow(localizations.detailGrowingSeason, widget.crop.growingSeason),
      _buildDetailRow(localizations.detailGrowingPeriod, '${widget.crop.growingDays} ${localizations.daysLabel}'),
      _buildDetailRow(localizations.detailWaterRequirement, widget.crop.waterRequirement),
      _buildDetailRow(localizations.detailSoilType, widget.crop.soilType),
      _buildDetailRow(localizations.detailTemperatureRange, widget.crop.temperatureRange),
      _buildDetailRow(localizations.detailExpectedYield, widget.crop.getFormattedYield()),
    ];
  }

  List<Widget> _buildSowingHarvestingInfo() {
    final localizations = AppLocalizations.of(context)!;
    return [
      _buildDetailRow(localizations.detailSowingMonths, widget.crop.sowingMonths.join(', ')),
      _buildDetailRow(localizations.detailHarvestingMonths, widget.crop.harvestingMonths.join(', ')),
    ];
  }

  Widget _buildVarietiesWidget() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.crop.commonVarieties.map((variety) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            variety,
            style: TextStyle(fontSize: 13, color: Colors.green.shade800),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefitsWidget() {
    return Column(
      children: widget.crop.benefits.map((benefit) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                benefit,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildCompanionCropsWidget() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.crop.companionCrops.map((companion) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thumb_up, size: 14, color: Colors.blue.shade600),
              const SizedBox(width: 6),
              Text(
                companion,
                style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvoidCropsWidget() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.crop.avoidCrops.map((avoid) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, size: 14, color: Colors.red.shade600),
              const SizedBox(width: 6),
              Text(
                avoid,
                style: TextStyle(fontSize: 13, color: Colors.red.shade800),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection(
      String title, {
        String? content,
        List<Widget> children = const [],
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        if (content != null)
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        if (children.isNotEmpty) ...children,
        const Divider(height: 32, color: Colors.grey),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return Icons.grass;
      case 'wheat':
        return Icons.eco;
      case 'maize':
        return Icons.agriculture;
      case 'tomato':
        return Icons.apple;
      case 'potato':
        return Icons.circle;
      case 'onion':
        return Icons.layers;
      case 'cotton':
        return Icons.spa;
      case 'soybean':
        return Icons.eco;
      default:
        return Icons.eco;
    }
  }
}