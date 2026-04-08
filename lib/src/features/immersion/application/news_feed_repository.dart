import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/logging/app_logger.dart';
import '../data/news_api_client.dart';
import '../domain/news_article.dart';

class NewsFeedRepository {
  NewsFeedRepository({required this.database, NewsApiClient? newsApiClient})
    : _newsApiClient = newsApiClient ?? NewsApiClient();

  final AppDatabase database;
  final NewsApiClient _newsApiClient;
  final Map<String, Future<List<NewsArticle>>> _inFlightRequests =
      <String, Future<List<NewsArticle>>>{};
  static const mixedCategories = <String>[
    'general',
    'business',
    'technology',
    'science',
    'health',
    'entertainment',
    'sports',
  ];

  void dispose() {
    _inFlightRequests.clear();
    _newsApiClient.dispose();
  }

  Future<List<NewsArticle>> loadTopHeadlines({
    String category = 'all',
    int pageSize = 12,
    bool forceRefresh = false,
  }) async {
    final requestKey = 'headlines::$category::$pageSize';
    final inFlight = _inFlightRequests[requestKey];
    if (inFlight != null) {
      AppLogger.info(
        'NewsFeedRepository',
        'Reusing in-flight headline request.',
        details: <String, Object?>{
          'category': category,
          'pageSize': pageSize,
          'forceRefresh': forceRefresh,
        },
      );
      return inFlight;
    }

    final cacheKey = _headlineCacheKey(category: category, pageSize: pageSize);
    if (!forceRefresh) {
      final cachedArticles = await _readCachedArticles(cacheKey);
      if (cachedArticles.isNotEmpty) {
        AppLogger.info(
          'NewsFeedRepository',
          'Headline cache hit.',
          details: <String, Object?>{
            'category': category,
            'pageSize': pageSize,
            'count': cachedArticles.length,
          },
        );
        return cachedArticles;
      }
    }

    final future = _loadHeadlinesAndCache(
      category: category,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
      cacheKey: cacheKey,
    );
    _inFlightRequests[requestKey] = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightRequests[requestKey], future)) {
        _inFlightRequests.remove(requestKey);
      }
    }
  }

  Future<List<NewsArticle>> searchGermanArticles(
    String query, {
    int pageSize = 12,
    bool forceRefresh = false,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return loadTopHeadlines(pageSize: pageSize, forceRefresh: forceRefresh);
    }

    final requestKey = 'search::${normalizedQuery.toLowerCase()}::$pageSize';
    final inFlight = _inFlightRequests[requestKey];
    if (inFlight != null) {
      AppLogger.info(
        'NewsFeedRepository',
        'Reusing in-flight search request.',
        details: <String, Object?>{
          'query': normalizedQuery,
          'pageSize': pageSize,
          'forceRefresh': forceRefresh,
        },
      );
      return inFlight;
    }

    final cacheKey = _searchCacheKey(
      query: normalizedQuery,
      pageSize: pageSize,
    );
    if (!forceRefresh) {
      final cachedArticles = await _readCachedArticles(cacheKey);
      if (cachedArticles.isNotEmpty) {
        AppLogger.info(
          'NewsFeedRepository',
          'Search cache hit.',
          details: <String, Object?>{
            'query': normalizedQuery,
            'pageSize': pageSize,
            'count': cachedArticles.length,
          },
        );
        return cachedArticles;
      }
    }

    final future = _searchAndCache(
      normalizedQuery,
      pageSize: pageSize,
      cacheKey: cacheKey,
    );
    _inFlightRequests[requestKey] = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlightRequests[requestKey], future)) {
        _inFlightRequests.remove(requestKey);
      }
    }
  }

  Future<void> warmStart({
    List<String> categories = const [
      'all',
      'general',
      'business',
      'technology',
    ],
    int pageSize = 12,
  }) async {
    for (final category in categories) {
      try {
        await loadTopHeadlines(
          category: category,
          pageSize: pageSize,
          forceRefresh: true,
        );
      } catch (_) {
        // Warm-up failures shouldn't block the app.
      }
    }
  }

  String _headlineCacheKey({required String category, required int pageSize}) {
    return 'top-headlines::$category::$pageSize';
  }

  String _searchCacheKey({required String query, required int pageSize}) {
    return 'search::${query.toLowerCase()}::$pageSize';
  }

  Future<List<NewsArticle>> _loadHeadlinesAndCache({
    required String category,
    required int pageSize,
    required bool forceRefresh,
    required String cacheKey,
  }) async {
    AppLogger.info(
      'NewsFeedRepository',
      'Loading top headlines.',
      details: <String, Object?>{
        'category': category,
        'pageSize': pageSize,
        'forceRefresh': forceRefresh,
      },
    );

    final articles = category == 'all'
        ? await _loadMixedTopHeadlines(
            pageSize: pageSize,
            forceRefresh: forceRefresh,
          )
        : await _newsApiClient.fetchGermanTopHeadlines(
            category: category,
            pageSize: pageSize,
            forceRefresh: forceRefresh,
          );
    await _storeArticles(cacheKey, articles);
    return articles;
  }

  Future<List<NewsArticle>> _searchAndCache(
    String query, {
    required int pageSize,
    required String cacheKey,
  }) async {
    AppLogger.info(
      'NewsFeedRepository',
      'Loading search results.',
      details: <String, Object?>{'query': query, 'pageSize': pageSize},
    );
    final articles = await _newsApiClient.searchGermanArticles(
      query,
      pageSize: pageSize,
    );
    await _storeArticles(cacheKey, articles);
    return articles;
  }

  Future<List<NewsArticle>> _loadMixedTopHeadlines({
    required int pageSize,
    required bool forceRefresh,
  }) async {
    final perCategorySize = (pageSize / mixedCategories.length).ceil() + 2;
    final futures = mixedCategories.map((category) {
      return _newsApiClient.fetchGermanTopHeadlines(
        category: category,
        pageSize: perCategorySize,
        forceRefresh: forceRefresh,
      );
    }).toList();

    final responses = await Future.wait(futures);
    final uniqueByUrl = <String, NewsArticle>{};

    for (final articles in responses) {
      for (final article in articles) {
        uniqueByUrl.putIfAbsent(article.url, () => article);
      }
    }

    final combined = uniqueByUrl.values.toList()
      ..sort((a, b) {
        final aTime = a.publishedAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.publishedAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

    return combined.take(pageSize).toList();
  }

  Future<List<NewsArticle>> _readCachedArticles(String cacheKey) async {
    final cachedEntry = await database.getNewsCacheEntry(cacheKey);
    if (cachedEntry == null || cachedEntry.payloadJson.trim().isEmpty) {
      return const <NewsArticle>[];
    }

    final decoded = jsonDecode(cachedEntry.payloadJson);
    if (decoded is! List) {
      return const <NewsArticle>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(NewsArticle.fromJson)
        .where((article) => article.url.trim().isNotEmpty)
        .toList();
  }

  Future<void> _storeArticles(
    String cacheKey,
    List<NewsArticle> articles,
  ) async {
    AppLogger.info(
      'NewsFeedRepository',
      'Persisting article cache entry.',
      details: <String, Object?>{
        'cacheKey': cacheKey,
        'count': articles.length,
      },
    );
    final payload = jsonEncode([
      for (final article in articles) article.toJson(),
    ]);
    await database.saveNewsCacheEntry(cacheKey: cacheKey, payloadJson: payload);
  }
}
