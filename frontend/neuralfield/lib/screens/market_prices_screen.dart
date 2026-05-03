import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/settings_menu.dart';
import '../api/api_service.dart';
import '../api/api_request.dart';
import '../api/api_response.dart';
import '../l10n/app_localizations.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final MarketMetaService _metaService = MarketMetaService();
  final MarketPricesService _pricesService = MarketPricesService();

  // Filter data - only state and district
  List<String> _states = [];
  List<String> _districts = [];
  String? _selectedState;
  String? _selectedDistrict;

  // Prices data
  List<MarketPriceItem> _allPrices = [];
  List<MarketPriceItem> _displayedPrices = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalPages = 0;
  bool _isLoadingFilters = true;
  bool _isLoadingPrices = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _metaService.dispose();
    _pricesService.dispose();
    super.dispose();
  }

  // ---------- META API ----------
  Future<void> _fetchMeta({String? state, String? district}) async {
    try {
      final request = MarketMetaRequest(state: state, district: district);
      final response = await _metaService.fetchMarketMeta(request);

      setState(() {
        if (state == null && district == null) {
          _states = response.data.states;
          _districts = [];
        } else if (state != null && district == null) {
          _districts = response.data.districts;
        }
        _isLoadingFilters = false;
      });
    } catch (e) {
      print('Error fetching meta: $e');
      setState(() => _isLoadingFilters = false);
    }
  }

  // ---------- PRICES API ----------
  Future<void> _fetchPrices({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _allPrices = [];
        _displayedPrices = [];
        _currentPage = 1;
        _error = null;
      });
    }

    if (_isLoadingPrices) return;

    setState(() => _isLoadingPrices = true);

    try {
      final request = MarketPricesRequest(
        state: _selectedState,
        district: _selectedDistrict,
        page: 1,
        limit: 10000,
      );
      final response = await _pricesService.fetchMarketPrices(request);

      setState(() {
        _allPrices = response.data;
        _totalPages = (_allPrices.length / _itemsPerPage).ceil();
        _currentPage = 1;
        _updateDisplayedPrices();
        _isLoadingPrices = false;
      });
    } catch (e) {
      print('Error fetching prices: $e');
      setState(() {
        _error = e.toString();
        _isLoadingPrices = false;
      });
    }
  }

  void _updateDisplayedPrices() {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _allPrices.length) {
      _displayedPrices = [];
    } else {
      _displayedPrices = _allPrices.sublist(
        start,
        end > _allPrices.length ? _allPrices.length : end,
      );
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    setState(() {
      _currentPage = page;
      _updateDisplayedPrices();
    });
  }

  void _nextPage() => _goToPage(_currentPage + 1);
  void _prevPage() => _goToPage(_currentPage - 1);

  Future<void> _fetchInitialData() async {
    await _fetchMeta();
    await _fetchPrices(isRefresh: true);
  }

  // ---------- FILTER HANDLERS ----------
  void _onStateChanged(String? state) async {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _districts = [];
    });
    if (state != null) await _fetchMeta(state: state);
    else await _fetchMeta();
    await _fetchPrices(isRefresh: true);
  }

  void _onDistrictChanged(String? district) async {
    setState(() {
      _selectedDistrict = district;
    });
    await _fetchPrices(isRefresh: true);
  }

  void _clearFilters() async {
    setState(() {
      _selectedState = null;
      _selectedDistrict = null;
      _districts = [];
    });
    await _fetchMeta();
    await _fetchPrices(isRefresh: true);
  }

  void _showSettingsMenu() => SettingsMenu.show(context);

  // ---------- CSV EXPORT ----------
  Future<void> _exportToCSV() async {
    final localizations = AppLocalizations.of(context)!;
    if (_allPrices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.noDataToExport)),
      );
      return;
    }

    try {
      List<String> lines = [];
      // CSV header using localized strings
      lines.add(
        '${localizations.csvHeaderName},'
            '${localizations.csvHeaderPrice},'
            '${localizations.csvHeaderMinPrice},'
            '${localizations.csvHeaderMaxPrice},'
            '${localizations.csvHeaderUnit},'
            '${localizations.csvHeaderChangePercent},'
            '${localizations.csvHeaderTrend},'
            '${localizations.csvHeaderMarket},'
            '${localizations.csvHeaderDistrict},'
            '${localizations.csvHeaderState},'
            '${localizations.csvHeaderLastUpdated}',
      );
      for (var item in _allPrices) {
        lines.add(
          '"${item.name}",'
              '"${item.formattedPrice}",'
              '"${item.formattedMinPrice}",'
              '"${item.formattedMaxPrice}",'
              '"${item.unit}",'
              '"${item.formattedPercentChange}",'
              '"${item.trend}",'
              '"${item.marketLocation}",'
              '"${item.district}",'
              '"${item.state}",'
              '"${item.formattedLastUpdated}"',
        );
      }

      final csvContent = lines.join('\n');
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'market_prices_$timestamp.csv';

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvContent);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: localizations.shareText,
        subject: localizations.shareSubject,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.exportedRecordsCount(_allPrices.length))),
        );
      }
    } catch (e) {
      print('Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.failedToExportFile)),
        );
      }
    }
  }

  // ---------- UI HELPERS ----------
  Widget _buildDropdown({
    required BuildContext context,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) {
    final localizations = AppLocalizations.of(context)!;
    if (isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(child: Text(localizations.loading, style: const TextStyle(color: Colors.grey))),
            const SizedBox(width: 8),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500)),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50), size: 24),
            items: [
              if (value != null)
                DropdownMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      const Icon(Icons.clear, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(localizations.clear, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ...items.map((item) => DropdownMenuItem(value: item, child: Text(item))),
            ],
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E2B)),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getEmojiForCrop(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato': return '🍅';
      case 'onion': return '🧅';
      case 'potato': return '🥔';
      case 'wheat': return '🌾';
      case 'rice': return '🍚';
      case 'green chilli': return '🌶️';
      case 'bhindi(ladies finger)': return '🌱';
      default: return '🚜';
    }
  }

  void _showPriceDetailDialog(MarketPriceItem item) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_getEmojiForCrop(item.name), style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B))),
                        const SizedBox(height: 4),
                        Text('${item.marketLocation}, ${item.district}', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow(context, localizations.priceLabel, item.formattedPrice),
              _buildDetailRow(context, localizations.minPriceLabel, item.formattedMinPrice),
              _buildDetailRow(context, localizations.maxPriceLabel, item.formattedMaxPrice),
              _buildDetailRow(context, localizations.unitLabel, item.unit),
              _buildDetailRow(context, localizations.changeLabel, '${item.formattedChange} (${item.formattedPercentChange})',
                  valueColor: item.changeColor),
              _buildDetailRow(context, localizations.trendLabel, item.trend.toUpperCase()),
              _buildDetailRow(context, localizations.marketLabel, item.marketLocation),
              _buildDetailRow(context, localizations.districtLabel, item.district),
              _buildDetailRow(context, localizations.stateLabel, item.state),
              _buildDetailRow(context, localizations.lastUpdatedLabel, item.formattedLastUpdated),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(localizations.closeButton, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          Flexible(
            child: Text(value,
                style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  // ---------- FIXED PRICE CARD (no overflow) ----------
  Widget _buildPriceCard(BuildContext context, MarketPriceItem item) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _showPriceDetailDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(_getEmojiForCrop(item.name), style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C3E2B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${item.marketLocation}, ${item.district}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(item.change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12, color: item.changeColor),
                            const SizedBox(width: 4),
                            Text(
                              '${item.formattedChange} (${item.formattedPercentChange})',
                              style: TextStyle(color: item.changeColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${localizations.updatedPrefix} ${item.formattedLastUpdated}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.formattedPrice,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                ),
                Text(
                  '/ ${item.unit}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- PAGINATION BAR ----------
  Widget _buildPaginationBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page, color: Color(0xFF4CAF50)),
            onPressed: _currentPage > 1 ? () => _goToPage(1) : null,
            tooltip: localizations.firstPageTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF4CAF50)),
            onPressed: _currentPage > 1 ? _prevPage : null,
            tooltip: localizations.previousPageTooltip,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getVisiblePageNumbers().map((page) {
                  final isActive = page == _currentPage;
                  return GestureDetector(
                    onTap: () => _goToPage(page),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF4CAF50) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        page.toString(),
                        style: TextStyle(
                          color: isActive ? Colors.white : const Color(0xFF2C3E2B),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF4CAF50)),
            onPressed: _currentPage < _totalPages ? _nextPage : null,
            tooltip: localizations.nextPageTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.last_page, color: Color(0xFF4CAF50)),
            onPressed: _currentPage < _totalPages ? () => _goToPage(_totalPages) : null,
            tooltip: localizations.lastPageTooltip,
          ),
        ],
      ),
    );
  }

  List<int> _getVisiblePageNumbers() {
    if (_totalPages <= 9) {
      return List.generate(_totalPages, (i) => i + 1);
    }
    int start = _currentPage - 4;
    if (start < 1) start = 1;
    int end = start + 8;
    if (end > _totalPages) {
      end = _totalPages;
      start = end - 8;
    }
    return List.generate(end - start + 1, (i) => start + i);
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: Text(
          localizations.marketPricesTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E2B)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF4CAF50)),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section – fixed layout
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: const Color(0xFFF5F7F3),
            child: Column(
              children: [
                if (_isLoadingFilters)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          context: context,
                          value: _selectedState,
                          items: _states,
                          hint: localizations.selectState,
                          onChanged: _onStateChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.download, color: Color(0xFF4CAF50)),
                            onPressed: _exportToCSV,
                            tooltip: localizations.exportToCsvTooltip,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50)),
                            onPressed: _clearFilters,
                            tooltip: localizations.clearFiltersTooltip,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedState != null) ...[
                    const SizedBox(height: 10),
                    _buildDropdown(
                      context: context,
                      value: _selectedDistrict,
                      items: _districts,
                      hint: localizations.selectDistrict,
                      onChanged: _onDistrictChanged,
                    ),
                  ],
                ],
              ],
            ),
          ),
          // Price list with pagination
          Expanded(
            child: _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(localizations.failedToLoadPrices, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_error!, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _fetchPrices(isRefresh: true),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                    child: Text(localizations.retryButton, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
                : _isLoadingPrices && _allPrices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    itemCount: _displayedPrices.length,
                    itemBuilder: (context, index) => _buildPriceCard(context, _displayedPrices[index]),
                  ),
                ),
                _buildPaginationBar(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}