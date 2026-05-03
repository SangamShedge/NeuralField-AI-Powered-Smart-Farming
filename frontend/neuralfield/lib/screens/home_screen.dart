import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_header.dart';
import '../widgets/weather_card.dart';
import '../widgets/tools_grid.dart';
import '../widgets/library_grid.dart';
// import '../widgets/alert_list.dart';
import '../widgets/news_section.dart';
import '../widgets/voice_input_fab.dart';
import '../widgets/settings_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<NewsSectionState> _newsSectionKey = GlobalKey<NewsSectionState>();
  bool _isNewsRefreshing = false;

  Future<void> _refreshNews() async {
    setState(() {
      _isNewsRefreshing = true;
    });
    await _newsSectionKey.currentState?.refreshNews();
    setState(() {
      _isNewsRefreshing = false;
    });
  }

  void _showSettingsMenu() {
    SettingsMenu.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppHeader(
        showMenuButton: true,
        onMenuPressed: _showSettingsMenu,
      ),
      body: _buildBody(context, localizations),
      floatingActionButton: const VoiceInputFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations localizations) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WeatherCard(),
          const SizedBox(height: 20),
          SectionHeader(
            title: localizations.smartFarmingToolsTitle,
            icon: Icons.auto_awesome,
            subtitle: localizations.aiPoweredRecommendationsSubtitleHS,
          ),
          const SizedBox(height: 12),
          const ToolsGrid(),
          const SizedBox(height: 28),
          SectionHeader(
            title: localizations.knowledgeHubTitle,
            icon: Icons.menu_book_outlined,
          ),
          const SizedBox(height: 12),
          const LibraryGrid(),
          const SizedBox(height: 28),
          // SectionHeader(
          //    title: 'Pest & Disease Alerts',
          //   icon: Icons.warning_amber_rounded,
          //   showBadge: true,
          // ),
          // const SizedBox(height: 12),
          // const AlertList(),
          // const SizedBox(height: 28),
          SectionHeader(
            title: localizations.agricultureNewsTitle,
            icon: Icons.newspaper,
            onRefresh: _refreshNews,
            isRefreshing: _isNewsRefreshing,
            refreshTooltip: localizations.refreshNewsTooltip,
          ),
          const SizedBox(height: 12),
          NewsSection(key: _newsSectionKey),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;
  final bool showBadge;
  final bool showViewAll;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final String? refreshTooltip;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.showBadge = false,
    this.showViewAll = false,
    this.onRefresh,
    this.isRefreshing = false,
    this.refreshTooltip,
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E2B),
                letterSpacing: -0.3,
              ),
            ),
            // if (showBadge) ...[
            //   const SizedBox(width: 8),
            //   Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFFF44336),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //      child: const Text(
            //                   '3',
            //       style: const TextStyle(
            //         fontSize: 11,
            //         fontWeight: FontWeight.w600,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ],
            const Spacer(),
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
                  tooltip: refreshTooltip ?? localizations.refreshNewsTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            if (showViewAll)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  localizations.viewAllLabel,
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