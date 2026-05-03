// lib/widgets/news_section.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../api/api_response.dart';
import '../services/cache_manager.dart';

class NewsSection extends StatefulWidget {
  const NewsSection({super.key});

  @override
  NewsSectionState createState() => NewsSectionState();
}

class NewsSectionState extends State<NewsSection> {
  // ---------- CACHE (managed by CacheManager) ----------
  final CacheManager _cache = CacheManager();
  static const _cacheDuration = Duration(minutes: 30);
  static bool _isBackgroundUpdating = false;

  // ---------- UI STATE ----------
  List<NewsItem> _displayNews = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _initializeWithCache();
  }

  void _initializeWithCache() async {
    // 1. If we have cached news, show it immediately
    if (_cache.cachedNews.isNotEmpty && _cache.newsTimestamp != null) {
      setState(() {
        _displayNews = List.from(_cache.cachedNews);
        _isLoading = false;
        _error = null;
      });

      // 2. If cache is stale, refresh in background
      final bool isCacheStale =
          DateTime.now().difference(_cache.newsTimestamp!) > _cacheDuration;
      if (isCacheStale && !_isBackgroundUpdating) {
        _performBackgroundRefresh();
      }
    } else {
      await _fetchNews(forceRefresh: true);
    }
  }

  Future<void> _performBackgroundRefresh() async {
    if (_isBackgroundUpdating) return;
    _isBackgroundUpdating = true;

    try {
      final response = await _newsService.fetchNews();
      final newNews = response.data;

      _cache.cachedNews = List.from(newNews);
      _cache.newsTimestamp = DateTime.now();

      if (mounted) {
        setState(() {
          _displayNews = List.from(newNews);
          _error = null;
        });
      }
    } catch (e) {
      print('Background news refresh failed: $e');
    } finally {
      _isBackgroundUpdating = false;
    }
  }

  Future<void> _fetchNews({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _isRefreshing = false;
      });
    }

    try {
      final response = await _newsService.fetchNews();
      final freshNews = response.data;

      _cache.cachedNews = List.from(freshNews);
      _cache.newsTimestamp = DateTime.now();

      if (mounted) {
        setState(() {
          _displayNews = List.from(freshNews);
          _isLoading = false;
          _isRefreshing = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        if (_cache.cachedNews.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.failedToRefresh} ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _isLoading = false;
            _isRefreshing = false;
          });
        } else {
          setState(() {
            _error = e.toString().replaceFirst('Exception: ', '');
            _isLoading = false;
            _isRefreshing = false;
          });
        }
      }
    }
  }

  Future<void> refreshNews() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchNews(forceRefresh: true);
  }

  void _showAllNews() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final localizations = AppLocalizations.of(context)!;
          List<NewsItem> allNews = _cache.cachedNews;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(
                maxHeight: 650,
                maxWidth: 500,
                minWidth: 300,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          localizations.allAgricultureNews,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E2B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () async {
                              setDialogState(() {});
                              try {
                                final response = await _newsService.fetchNews();
                                final freshNews = response.data;
                                _cache.cachedNews = List.from(freshNews);
                                _cache.newsTimestamp = DateTime.now();
                                if (mounted) {
                                  setState(() {
                                    _displayNews = List.from(freshNews);
                                  });
                                }
                                setDialogState(() {
                                  allNews = freshNews;
                                });
                              } catch (e) {
                                // keep existing
                              }
                            },
                            tooltip: localizations.refresh,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: allNews.isEmpty
                        ? Center(child: Text(localizations.noNewsAvailable))
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: allNews.length,
                      itemBuilder: (context, index) {
                        final news = allNews[index];
                        return _buildNewsCard(news, context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNewsDetail(NewsItem news) {
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                news.getSourceIcon(),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  news.getSourceDisplayName().toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (news.image != null && news.image!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                news.image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                          const SizedBox(height: 8),
                                          Text(
                                            localizations.imageNotAvailable,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E2B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          news.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${localizations.publishedLabel} ${news.getFormattedDate()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse(news.link);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: Text(localizations.readFullArticle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsCard(NewsItem news, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _showNewsDetail(news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                news.getSourceIcon(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7F3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            news.getSourceDisplayName().toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        news.getFormattedDate(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E2B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      );
    }

    if (_error != null && _displayNews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(
                localizations.unableToLoadNews,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchNews(forceRefresh: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_displayNews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            localizations.noNewsAvailable,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final displayNews = _displayNews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayNews.map((news) => _buildNewsCard(news, context)),
        if (_displayNews.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton(
                onPressed: _showAllNews,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  localizations.viewAllNews,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _newsService.dispose();
    super.dispose();
  }
}