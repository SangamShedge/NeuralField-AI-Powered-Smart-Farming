import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../api/api_service.dart';
import '../../api/api_response.dart';
import '../../providers/locale_provider.dart';

class CultivationTipsScreen extends StatefulWidget {
  const CultivationTipsScreen({super.key});

  @override
  State<CultivationTipsScreen> createState() => _CultivationTipsScreenState();
}

class _CultivationTipsScreenState extends State<CultivationTipsScreen> {
  TipCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  List<CultivationTip> _allTips = [];
  List<CultivationTip> _filteredTips = [];
  bool _isLoading = true;
  String? _errorMessage;

  final CultivationTipsService _tipsService = CultivationTipsService();

  // Track current language
  String _currentLang = 'en';

  @override
  void initState() {
    super.initState();
    // No fetch here – will be done in didChangeDependencies after locale is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current locale from provider
    final localeProvider = Provider.of<LocaleProvider>(context);
    final newLang = localeProvider.locale.languageCode;

    // Fetch tips if language changed or first load (empty list)
    if (_currentLang != newLang || _allTips.isEmpty) {
      _currentLang = newLang;
      _fetchTipsWithLanguage();
    }
  }

  Future<void> _fetchTipsWithLanguage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pass the current language to the service
      final response = await _tipsService.getAllTips(language: _currentLang);

      if (response.isSuccess && response.data.isNotEmpty) {
        setState(() {
          _allTips = response.data;
          _filteredTips = response.data;
          _isLoading = false;
        });
      } else {
        final localizations = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = localizations.noCultivationTipsFound;
          _isLoading = false;
        });
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = '${localizations.failedToLoadTips} $e';
        _isLoading = false;
      });
    }
  }

  void _updateFilters() {
    setState(() {
      _filteredTips = _tipsService.getTipsByCategory(_allTips, _selectedCategory);
      if (_searchQuery.isNotEmpty) {
        _filteredTips = _tipsService.searchTips(_filteredTips, _searchQuery);
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _updateFilters();
      }
    });
  }

  @override
  void dispose() {
    _tipsService.dispose();
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
            hintText: localizations.searchCultivationTipsHint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _updateFilters();
            });
          },
        )
            : Text(localizations.cultivationTipsTitle),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.loadingCultivationTips,
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
              onPressed: _fetchTipsWithLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
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
        // Category chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip(null),
                ...TipCategory.values.map((category) => _buildCategoryChip(category)),
              ],
            ),
          ),
        ),

        // Results info
        if (_searchQuery.isNotEmpty || _selectedCategory != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.showingTipsCount(_filteredTips.length, _allTips.length),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (_searchQuery.isNotEmpty || _selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = null;
                        _updateFilters();
                      });
                    },
                    child: Text(localizations.clearAllFilters),
                  ),
              ],
            ),
          ),

        // Tips list
        Expanded(
          child: _filteredTips.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  localizations.noTipsFound,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? localizations.tryDifferentSearchTerm
                      : localizations.tryDifferentCategory,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredTips.length,
            itemBuilder: (context, index) {
              return _buildTipCard(_filteredTips[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(TipCategory? category) {
    final isSelected = _selectedCategory == category;
    final localizations = AppLocalizations.of(context)!;
    final displayName = category == null ? localizations.all : category.displayName;
    final icon = category?.icon ?? Icons.all_inclusive;
    final color = category?.color ?? const Color(0xFF9C27B0);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(displayName),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
            _updateFilters();
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTipCard(CultivationTip tip) {
    final category = tip.tipCategory;
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
              builder: (context) => TipDetailScreen(tip: tip),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: category.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tip.difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tip.difficultyText,
                      style: TextStyle(
                        fontSize: 11,
                        color: tip.difficultyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tip.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.access_time, '${tip.estimatedTime} ${localizations.minutesUnit}', Colors.grey),
                  _buildInfoChip(Icons.checklist, '${tip.steps.length} ${localizations.stepsUnit}', Colors.grey),
                  _buildInfoChip(Icons.wb_sunny, tip.season, Colors.grey),
                  _buildInfoChip(Icons.emoji_events, tip.benefits.length.toString(), Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// Tip Detail Screen
class TipDetailScreen extends StatelessWidget {
  final CultivationTip tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final category = tip.tipCategory;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tip.title),
        backgroundColor: category.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizations.shareFeatureComingSoon)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    category.color.withOpacity(0.1),
                    category.color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      size: 60,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickInfo(
                        Icons.access_time,
                        localizations.timeRequired,
                        '${tip.estimatedTime} ${localizations.minutesUnit}',
                        category.color,
                      ),
                      _buildQuickInfo(
                        Icons.star,
                        localizations.difficultyLabel,
                        tip.difficultyText,
                        tip.difficultyColor,
                      ),
                      _buildQuickInfo(
                        Icons.wb_sunny,
                        localizations.bestSeason,
                        tip.season,
                        category.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  _buildSection(localizations.sectionDescription, tip.description, category.color),
                  const SizedBox(height: 16),

                  // Steps
                  _buildSection(localizations.sectionStepByStepGuide, null, category.color,
                      children: _buildSteps()),
                  const SizedBox(height: 16),

                  // Benefits
                  _buildSection(localizations.sectionBenefits, null, category.color,
                      children: _buildBenefits()),
                  const SizedBox(height: 16),

                  // Required Materials
                  _buildSection(localizations.sectionMaterialsRequired, null, category.color,
                      children: _buildMaterials()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildSteps() {
    return tip.steps.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tip.tipCategory.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.key + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tip.tipCategory.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildBenefits() {
    return tip.benefits.map((benefit) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(benefit)),
        ],
      ),
    )).toList();
  }

  List<Widget> _buildMaterials() {
    return tip.requiredMaterials.map((material) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.inventory, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(material)),
        ],
      ),
    )).toList();
  }

  Widget _buildSection(String title, String? content, Color color, {List<Widget> children = const []}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        if (content != null)
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        if (children.isNotEmpty) ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}