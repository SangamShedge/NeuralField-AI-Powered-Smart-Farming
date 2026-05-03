import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_header.dart';
import '../widgets/settings_menu.dart';
import '../api/api_service.dart';
import '../api/api_request.dart';
import '../api/api_response.dart';
import 'market_prices_screen.dart';
import '../l10n/app_localizations.dart';

// ------------------------------------------------------------
// SectionHeader – unchanged except strings localized
// ------------------------------------------------------------
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final bool showBadge;
  final bool showViewAll;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.showBadge = false,
    this.showViewAll = false,
    this.onRefresh,
    this.isRefreshing = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E2B),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localizations.badgeCount,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            if (onRefresh != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: AnimatedRotation(
                    turns: isRefreshing ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: const Icon(Icons.refresh, color: Color(0xFF4CAF50), size: 20),
                  ),
                  onPressed: onRefresh,
                  tooltip: localizations.refreshTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            if (showViewAll && onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  localizations.viewAll,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------
// MAIN MARKET SCREEN (updated dashboard filters – commodity removed)
// ------------------------------------------------------------
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // ---------- Dashboard services and data ----------
  final MarketMetaService _dashboardMetaService = MarketMetaService();
  final MarketDashboardService _dashboardService = MarketDashboardService();

  // Dashboard filters (commodity removed)
  List<String> _dashboardStates = [];
  List<String> _dashboardDistricts = [];
  String? _selectedDashboardState;
  String? _selectedDashboardDistrict;

  bool _isLoadingDashboardFilters = true;
  bool _isLoadingDashboard = true;
  bool _isRefreshingDashboard = false;
  String? _dashboardError;
  MarketDashboardResponse? _dashboard;

  // ---------- Comparison services and data (independent) ----------
  final MarketMetaService _comparisonMetaService = MarketMetaService();
  final MarketComparisonService _comparisonService = MarketComparisonService();

  List<String> _comparisonStates = [];
  List<String> _comparisonCommodities = [];
  String? _selectedComparisonState;
  String? _selectedComparisonCommodity;
  bool _isLoadingComparisonFilters = true;

  MarketComparisonResponse? _comparison;
  bool _isLoadingComparison = false;
  String? _comparisonError;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _dashboardMetaService.dispose();
    _dashboardService.dispose();
    _comparisonMetaService.dispose();
    _comparisonService.dispose();
    super.dispose();
  }

  // ---------- DASHBOARD META ----------
  Future<void> _fetchDashboardMeta({String? state, String? district}) async {
    try {
      final request = MarketMetaRequest(state: state, district: district);
      final response = await _dashboardMetaService.fetchMarketMeta(request);

      setState(() {
        if (state == null && district == null) {
          _dashboardStates = response.data.states;
          _dashboardDistricts = [];
        } else if (state != null && district == null) {
          _dashboardDistricts = response.data.districts;
        }
        _isLoadingDashboardFilters = false;
      });
    } catch (e) {
      print('Error fetching dashboard meta: $e');
      setState(() => _isLoadingDashboardFilters = false);
    }
  }

  // ---------- DASHBOARD API ----------
  Future<void> _fetchDashboard({bool isRefresh = false}) async {
    if (isRefresh) setState(() => _isRefreshingDashboard = true);
    else setState(() => _isLoadingDashboard = true);
    setState(() => _dashboardError = null);

    try {
      final request = MarketDashboardRequest(
        state: _selectedDashboardState,
        district: _selectedDashboardDistrict,
      );
      final response = await _dashboardService.fetchMarketDashboard(request);
      setState(() {
        _dashboard = response;
        _isLoadingDashboard = false;
        _isRefreshingDashboard = false;
      });
    } catch (e) {
      print('Error fetching dashboard: $e');
      setState(() {
        _dashboardError = e.toString();
        _isLoadingDashboard = false;
        _isRefreshingDashboard = false;
      });
    }
  }

  // ---------- COMPARISON META (independent) ----------
  Future<void> _fetchComparisonMeta({String? state}) async {
    try {
      final request = MarketMetaRequest(state: state, district: null);
      final response = await _comparisonMetaService.fetchMarketMeta(request);

      setState(() {
        if (state == null) {
          _comparisonStates = response.data.states;
          _comparisonCommodities = [];
        } else {
          _comparisonCommodities = response.data.commodities;
        }
        _isLoadingComparisonFilters = false;
      });
    } catch (e) {
      print('Error fetching comparison meta: $e');
      setState(() => _isLoadingComparisonFilters = false);
    }
  }

  // ---------- COMPARISON API ----------
  Future<void> _fetchComparison() async {
    if (_selectedComparisonState == null || _selectedComparisonCommodity == null) {
      setState(() {
        _comparison = null;
        _comparisonError = null;
      });
      return;
    }

    setState(() {
      _isLoadingComparison = true;
      _comparisonError = null;
    });

    try {
      final request = MarketComparisonRequest(
        state: _selectedComparisonState!,
        commodity: _selectedComparisonCommodity!,
      );
      final response = await _comparisonService.fetchMarketComparison(request);
      setState(() {
        _comparison = response;
        _isLoadingComparison = false;
      });
    } catch (e) {
      print('Error fetching comparison: $e');
      setState(() {
        _comparisonError = e.toString();
        _isLoadingComparison = false;
      });
    }
  }

  // ---------- INITIAL DATA & REFRESH ----------
  Future<void> _fetchInitialData() async {
    await _fetchDashboardMeta();
    await _fetchDashboard();
    await _fetchComparisonMeta();
  }

  // Dashboard refresh: clears all dashboard filters and fetches fresh data
  Future<void> _refreshDashboard() async {
    setState(() {
      _selectedDashboardState = null;
      _selectedDashboardDistrict = null;
      _dashboardDistricts = [];
    });
    await _fetchDashboardMeta();
    await _fetchDashboard();
  }

  // ---------- DASHBOARD HANDLERS (progressive layout, commodity removed) ----------
  void _onDashboardStateChanged(String? state) async {
    setState(() {
      _selectedDashboardState = state;
      _selectedDashboardDistrict = null;
      _dashboardDistricts = [];
    });
    if (state != null) await _fetchDashboardMeta(state: state);
    else await _fetchDashboardMeta();
    await _fetchDashboard();
  }

  void _onDashboardDistrictChanged(String? district) async {
    setState(() {
      _selectedDashboardDistrict = district;
    });
    // No longer fetching meta for commodities
    await _fetchDashboard();
  }

  // ---------- COMPARISON HANDLERS ----------
  void _onComparisonStateChanged(String? state) async {
    setState(() {
      _selectedComparisonState = state;
      _selectedComparisonCommodity = null;
      _comparisonCommodities = [];
      _comparison = null;
    });
    if (state != null) await _fetchComparisonMeta(state: state);
    else await _fetchComparisonMeta();
  }

  void _onComparisonCommodityChanged(String? commodity) async {
    setState(() => _selectedComparisonCommodity = commodity);
    await _fetchComparison();
  }

  // Comparison refresh: clears comparison filters and resets dropdowns
  void _refreshComparison() async {
    setState(() {
      _selectedComparisonState = null;
      _selectedComparisonCommodity = null;
      _comparisonCommodities = [];
      _comparison = null;
    });
    await _fetchComparisonMeta();
  }

  // ---------- COMMON UI HELPERS ----------
  void _showSettingsMenu() => SettingsMenu.show(context);
  void _navigateToMarketPrices() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketPricesScreen()));
  }

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

  // Dashboard filter builder (progressive: state, then district – commodity removed)
  Widget _buildDashboardFilters(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoadingDashboardFilters) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // State dropdown (always visible)
        if (_selectedDashboardState == null)
          _buildDropdown(
            context: context,
            value: _selectedDashboardState,
            items: _dashboardStates,
            hint: localizations.selectState,
            onChanged: _onDashboardStateChanged,
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  context: context,
                  value: _selectedDashboardState,
                  items: _dashboardStates,
                  hint: localizations.selectState,
                  onChanged: _onDashboardStateChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  context: context,
                  value: _selectedDashboardDistrict,
                  items: _dashboardDistricts,
                  hint: localizations.selectDistrict,
                  onChanged: _onDashboardDistrictChanged,
                  isLoading: _isLoadingDashboardFilters && _dashboardDistricts.isEmpty,
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context, String title, TopGainerLoser data, bool isGainer) {
    final localizations = AppLocalizations.of(context)!;
    final bgColor = isGainer ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final accentColor = isGainer ? Colors.green.shade700 : Colors.red.shade700;
    final percentFormatted = '${data.percent >= 0 ? '+' : ''}${data.percent.toStringAsFixed(1)}%';

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(isGainer ? Icons.trending_up : Icons.trending_down, size: 18, color: accentColor),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.commodity,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isGainer ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: accentColor),
                    const SizedBox(width: 4),
                    Text(percentFormatted, style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(data.trend.toUpperCase(), style: TextStyle(fontSize: 9, color: accentColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, DashboardStats stats) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.marketOverview, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(localizations.commodities, stats.totalCommodities.toString()),
                _buildStatItem(localizations.markets, stats.totalMarkets.toString()),
                _buildStatItem(localizations.avgPrice, '₹${NumberFormat('#,##0.00').format(stats.avgPrice)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
      ],
    );
  }

  Widget _buildTrendingList(BuildContext context, List<TrendingCommodity> trending) {
    final localizations = AppLocalizations.of(context)!;
    final topThree = trending.take(3).toList();
    if (topThree.isEmpty) return const SizedBox.shrink();

    String _getTrendingIcon(String commodity) {
      switch (commodity.toLowerCase()) {
        case 'onion': return '🧅';
        case 'tomato': return '🍅';
        case 'potato': return '🥔';
        case 'wheat': return '🌾';
        case 'rice': return '🍚';
        default: return '🚜';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.whatshot, size: 18, color: Color(0xFF4CAF50)),
                const SizedBox(width: 6),
                Text(localizations.trendingNow, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B))),
              ],
            ),
            const SizedBox(height: 12),
            ...topThree.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final priority = index + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$priority',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_getTrendingIcon(item.commodity), style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.commodity,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPricesCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToMarketPrices,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.marketPrices,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizations.marketPricesSubtitle,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- COMPARISON SECTION (unchanged) ----------
  Widget _buildComparisonSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localizations.marketComparison,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50), size: 20),
              onPressed: _refreshComparison,
              tooltip: localizations.resetComparisonFilters,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedComparisonState == null)
          _buildDropdown(
            context: context,
            value: _selectedComparisonState,
            items: _comparisonStates,
            hint: localizations.selectState,
            onChanged: _onComparisonStateChanged,
            isLoading: _isLoadingComparisonFilters && _comparisonStates.isEmpty,
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  context: context,
                  value: _selectedComparisonState,
                  items: _comparisonStates,
                  hint: localizations.selectState,
                  onChanged: _onComparisonStateChanged,
                  isLoading: _isLoadingComparisonFilters && _comparisonStates.isEmpty,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  context: context,
                  value: _selectedComparisonCommodity,
                  items: _comparisonCommodities,
                  hint: localizations.selectCommodity,
                  onChanged: _onComparisonCommodityChanged,
                  isLoading: _isLoadingComparisonFilters && _comparisonCommodities.isEmpty,
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        // Comparison result
        if (_isLoadingComparison)
          const Center(child: CircularProgressIndicator())
        else if (_comparisonError != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text(localizations.failedToLoadComparison(_comparisonError!),
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _fetchComparison,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                  child: Text(localizations.retry, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        else if (_comparison != null && _comparison!.data.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.compare_arrows, size: 18, color: const Color(0xFF4CAF50)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            localizations.bestPriceFor(_comparison!.commodity),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E2B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFF4CAF50), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(localizations.bestMarket, style: TextStyle(fontSize: 11, color: Colors.green.shade800)),
                                Text(_comparison!.bestMarket,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                          Text(_comparison!.data.firstWhere((e) => e.isBest).formattedPrice,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(localizations.otherMarkets, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ..._comparison!.data.where((e) => !e.isBest).map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.location_city, size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.market, style: const TextStyle(fontSize: 13))),
                            Text(item.formattedPrice, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            )
          else if (_selectedComparisonState != null && _selectedComparisonCommodity != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(localizations.noComparisonDataAvailable)),
              ),
      ],
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppHeader(
        showMenuButton: true,
        onMenuPressed: _showSettingsMenu,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: const Color(0xFF4CAF50),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard SectionHeader
              SectionHeader(
                title: localizations.marketDashboard,
                icon: Icons.dashboard,
                subtitle: localizations.marketDashboardSubtitle,
                onRefresh: _refreshDashboard,
                isRefreshing: _isRefreshingDashboard,
              ),
              const SizedBox(height: 18),

              // Dashboard filters (progressive layout, commodity removed)
              _buildDashboardFilters(context),

              // Dashboard content (loading / error / data)
              if (_isLoadingDashboard)
                const Center(child: CircularProgressIndicator())
              else if (_dashboardError != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(localizations.failedToLoadDashboard, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(_dashboardError!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(localizations.retry, style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              else if (_dashboard != null) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopCard(context, localizations.topGainer, _dashboard!.summary.topGainer, true),
                        const SizedBox(width: 12),
                        _buildTopCard(context, localizations.topLoser, _dashboard!.summary.topLoser, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildStatsCard(context, _dashboard!.stats),
                  const SizedBox(height: 18),

                  _buildTrendingList(context, _dashboard!.trending),
                  const SizedBox(height: 18),

                  _buildMarketPricesCard(context),
                  const SizedBox(height: 24),

                  _buildComparisonSection(context),
                  const SizedBox(height: 20),
                ],
            ],
          ),
        ),
      ),
    );
  }
}