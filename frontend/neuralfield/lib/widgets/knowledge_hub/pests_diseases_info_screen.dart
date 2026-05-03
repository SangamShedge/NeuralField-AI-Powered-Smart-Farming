import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../api/api_service.dart';
import '../../api/api_response.dart';
import '../../providers/locale_provider.dart';

class PestsDiseasesInfoScreen extends StatefulWidget {
  const PestsDiseasesInfoScreen({super.key});

  @override
  State<PestsDiseasesInfoScreen> createState() => _PestsDiseasesInfoScreenState();
}

class _PestsDiseasesInfoScreenState extends State<PestsDiseasesInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;

  List<Pest> _allPests = [];
  List<Pest> _filteredPests = [];
  List<Disease> _allDiseases = [];
  List<Disease> _filteredDiseases = [];

  bool _isLoadingPests = true;
  bool _isLoadingDiseases = true;
  String? _pestsError;
  String? _diseasesError;

  final PestEncyclopediaService _pestService = PestEncyclopediaService();
  final DiseaseEncyclopediaService _diseaseService = DiseaseEncyclopediaService();

  String _currentLang = 'en';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeProvider = Provider.of<LocaleProvider>(context);
    final newLang = localeProvider.locale.languageCode;

    if (_currentLang != newLang || (_allPests.isEmpty && _allDiseases.isEmpty)) {
      _currentLang = newLang;
      _fetchPestsWithLanguage();
      _fetchDiseasesWithLanguage();
    }
  }

  Future<void> _fetchPestsWithLanguage() async {
    setState(() {
      _isLoadingPests = true;
      _pestsError = null;
    });
    try {
      final response = await _pestService.getAllPests(language: _currentLang);
      if (response.isSuccess && response.data.isNotEmpty) {
        setState(() {
          _allPests = response.data;
          _filteredPests = response.data;
          _isLoadingPests = false;
        });
      } else {
        final localizations = AppLocalizations.of(context)!;
        setState(() {
          _pestsError = localizations.noPestsFound;
          _isLoadingPests = false;
        });
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      setState(() {
        _pestsError = '${localizations.failedToLoadPests} $e';
        _isLoadingPests = false;
      });
    }
  }

  Future<void> _fetchDiseasesWithLanguage() async {
    setState(() {
      _isLoadingDiseases = true;
      _diseasesError = null;
    });
    try {
      final response = await _diseaseService.getAllDiseases(language: _currentLang);
      if (response.isSuccess && response.data.isNotEmpty) {
        setState(() {
          _allDiseases = response.data;
          _filteredDiseases = response.data;
          _isLoadingDiseases = false;
        });
      } else {
        final localizations = AppLocalizations.of(context)!;
        setState(() {
          _diseasesError = localizations.noDiseasesFound;
          _isLoadingDiseases = false;
        });
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      setState(() {
        _diseasesError = '${localizations.failedToLoadDiseases} $e';
        _isLoadingDiseases = false;
      });
    }
  }

  void _updateFilters() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredPests = _allPests;
        _filteredDiseases = _allDiseases;
      } else {
        _filteredPests = _pestService.searchPests(_allPests, _searchQuery);
        _filteredDiseases = _diseaseService.searchDiseases(_allDiseases, _searchQuery);
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
    _tabController.dispose();
    _pestService.dispose();
    _diseaseService.dispose();
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
            hintText: localizations.searchPestsDiseasesHint,
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
            : Text(localizations.pestsDiseasesTitle),
        backgroundColor: const Color(0xFFF44336),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.bug_report), text: localizations.tabPests),
            Tab(icon: const Icon(Icons.sick), text: localizations.tabDiseases),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPestsTab(),
          _buildDiseasesTab(),
        ],
      ),
    );
  }

  Widget _buildPestsTab() {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoadingPests) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pestsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_pestsError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPestsWithLanguage,
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.searchResultsPests(_filteredPests.length)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _updateFilters();
                      if (_isSearching) _isSearching = false;
                    });
                  },
                  child: Text(localizations.clear),
                ),
              ],
            ),
          ),
        Expanded(
          child: _filteredPests.isEmpty
              ? Center(child: Text(localizations.noPestsFound))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredPests.length,
            itemBuilder: (context, index) {
              return _buildPestCard(_filteredPests[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiseasesTab() {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoadingDiseases) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_diseasesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_diseasesError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDiseasesWithLanguage,
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localizations.searchResultsDiseases(_filteredDiseases.length)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _updateFilters();
                      if (_isSearching) _isSearching = false;
                    });
                  },
                  child: Text(localizations.clear),
                ),
              ],
            ),
          ),
        Expanded(
          child: _filteredDiseases.isEmpty
              ? Center(child: Text(localizations.noDiseasesFound))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredDiseases.length,
            itemBuilder: (context, index) {
              return _buildDiseaseCard(_filteredDiseases[index]);
            },
          ),
        ),
      ],
    );
  }

  // ----- Helper methods for images (using imageAsset) -----
  Widget _buildPestImage(Pest pest) {
    final imageUrl = pest.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(pest.pestType.icon, color: pest.severityEnum.color, size: 30);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(pest.pestType.icon, color: pest.severityEnum.color, size: 30),
      ),
    );
  }

  Widget _buildDiseaseImage(Disease disease) {
    final imageUrl = disease.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(disease.diseaseType.icon, color: disease.severityEnum.color, size: 30);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(disease.diseaseType.icon, color: disease.severityEnum.color, size: 30),
      ),
    );
  }

  // ----- Pest Card (with image) -----
  Widget _buildPestCard(Pest pest) {
    final localizations = AppLocalizations.of(context)!;
    final severityColor = pest.severityEnum.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PestDetailScreen(pest: pest)),
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildPestImage(pest),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pest.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          pest.scientificName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pest.severityEnum.displayName,
                      style: TextStyle(fontSize: 12, color: severityColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pest.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.type_specimen, pest.pestType.displayName),
                  _buildInfoChip(Icons.calendar_today, pest.activeSeason),
                  _buildInfoChip(Icons.bug_report, localizations.cropsCount(pest.affectedCrops.length)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- Disease Card (with image) -----
  Widget _buildDiseaseCard(Disease disease) {
    final localizations = AppLocalizations.of(context)!;
    final severityColor = disease.severityEnum.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiseaseDetailScreen(disease: disease)),
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildDiseaseImage(disease),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(disease.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          disease.scientificName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      disease.severityEnum.displayName,
                      style: TextStyle(fontSize: 12, color: severityColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                disease.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.medical_information, disease.diseaseType.displayName),
                  _buildInfoChip(Icons.wb_twilight, disease.favorableConditions.split(',').first),
                  _buildInfoChip(Icons.eco, localizations.cropsCount(disease.affectedCrops.length)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== PEST DETAIL SCREEN (with imageAsset) ==========
class PestDetailScreen extends StatelessWidget {
  final Pest pest;
  const PestDetailScreen({super.key, required this.pest});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final severityColor = pest.severityEnum.color;
    return Scaffold(
      appBar: AppBar(
        title: Text(pest.name),
        backgroundColor: const Color(0xFFF44336),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF44336).withOpacity(0.1),
                    const Color(0xFFF44336).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: Container(
                      width: 120,
                      height: 120,
                      color: const Color(0xFFF44336).withOpacity(0.2),
                      child: pest.imageUrl != null
                          ? Image.network(
                        pest.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(pest.pestType.icon, size: 60, color: const Color(0xFFF44336)),
                      )
                          : Icon(pest.pestType.icon, size: 60, color: const Color(0xFFF44336)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(pest.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(pest.scientificName, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBadge(localizations.typeLabel, pest.pestType.displayName, severityColor),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionDescription, pest.description),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionSymptoms, null,
                      children: pest.symptoms.map((s) => _buildBullet(Icons.warning, Colors.orange, s)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionOrganicControl, null,
                      children: pest.organicControls.map((c) => _buildBullet(Icons.eco, Colors.green, c)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionChemicalControl, null,
                      children: pest.chemicalControls.map((c) => _buildBullet(Icons.science, Colors.blue, c)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionPreventiveMeasures, null,
                      children: pest.preventiveMeasures.map((m) => _buildBullet(Icons.shield, Colors.teal, m)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionAffectedCrops, null,
                      children: [
                        Wrap(spacing: 8, runSpacing: 8,
                          children: pest.affectedCrops.map((c) => Chip(label: Text(c), backgroundColor: Colors.grey[200])).toList(),
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(IconData icon, Color color, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(text))]),
  );
  Widget _buildInfoBadge(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: color)), Text(value, style: TextStyle(color: color))]),
  );
  Widget _buildSection(String title, String? content, {List<Widget> children = const []}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (content != null) Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      if (children.isNotEmpty) ...children,
      const Divider(height: 24),
    ],
  );
}

// ========== DISEASE DETAIL SCREEN (with imageAsset) ==========
class DiseaseDetailScreen extends StatelessWidget {
  final Disease disease;
  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final severityColor = disease.severityEnum.color;
    return Scaffold(
      appBar: AppBar(title: Text(disease.name), backgroundColor: const Color(0xFFF44336), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFF44336).withOpacity(0.1), const Color(0xFFF44336).withOpacity(0.05)],
                ),
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: Container(
                      width: 120,
                      height: 120,
                      color: const Color(0xFFF44336).withOpacity(0.2),
                      child: disease.imageUrl != null
                          ? Image.network(
                        disease.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(disease.diseaseType.icon, size: 60, color: const Color(0xFFF44336)),
                      )
                          : Icon(disease.diseaseType.icon, size: 60, color: const Color(0xFFF44336)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(disease.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(disease.scientificName, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 8, children: [
                    _buildInfoBadge(localizations.typeLabel, disease.diseaseType.displayName, severityColor),
                    const SizedBox(width: 8),
                    _buildInfoBadge(localizations.severityLabel, disease.severityEnum.displayName, severityColor),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionDescription, disease.description),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionFavorableConditions, disease.favorableConditions),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionSymptoms, null,
                      children: disease.symptoms.map((s) => _buildBullet(Icons.warning, Colors.orange, s)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionOrganicControl, null,
                      children: disease.organicControls.map((c) => _buildBullet(Icons.eco, Colors.green, c)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionChemicalControl, null,
                      children: disease.chemicalControls.map((c) => _buildBullet(Icons.science, Colors.blue, c)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionPreventiveMeasures, null,
                      children: disease.preventiveMeasures.map((m) => _buildBullet(Icons.shield, Colors.teal, m)).toList()),
                  const SizedBox(height: 16),
                  _buildSection(localizations.sectionAffectedCrops, null,
                      children: [
                        Wrap(spacing: 8, runSpacing: 8,
                          children: disease.affectedCrops.map((c) => Chip(label: Text(c), backgroundColor: Colors.grey[200])).toList(),
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBullet(IconData icon, Color color, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(text))]),
  );
  Widget _buildInfoBadge(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: color)), Text(value, style: TextStyle(color: color))]),
  );
  Widget _buildSection(String title, String? content, {List<Widget> children = const []}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (content != null) Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      if (children.isNotEmpty) ...children,
      const Divider(height: 24),
    ],
  );
}