import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/news_api_config.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/news_article.dart';

class NewsApiClient {
  NewsApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Map<String, Future<List<NewsArticle>>> _headlineCache =
      <String, Future<List<NewsArticle>>>{};

  void dispose() {
    _headlineCache.clear();
    _httpClient.close();
  }

  Future<List<NewsArticle>> fetchGermanTopHeadlines({
    String category = 'general',
    int pageSize = 12,
    bool forceRefresh = false,
  }) {
    final cacheKey = '$category::$pageSize';
    if (!forceRefresh) {
      final cached = _headlineCache[cacheKey];
      if (cached != null) {
        return cached;
      }
    }

    AppLogger.info(
      'NewsApiClient',
      'Requesting german top headlines.',
      details: <String, Object?>{
        'category': category,
        'pageSize': pageSize,
        'forceRefresh': forceRefresh,
      },
    );
    late final Future<List<NewsArticle>> future;
    future = _requestArticles(
      path: '/top-headlines',
      queryParameters: {
        'country': 'de',
        'category': category,
        'pageSize': '$pageSize',
      },
    ).catchError((Object error, StackTrace stackTrace) {
      if (identical(_headlineCache[cacheKey], future)) {
        _headlineCache.remove(cacheKey);
      }
      Error.throwWithStackTrace(error, stackTrace);
    });

    _headlineCache[cacheKey] = future;
    return future;
  }

  Future<List<NewsArticle>> searchGermanArticles(
    String query, {
    int pageSize = 12,
  }) {
    AppLogger.info(
      'NewsApiClient',
      'Searching german articles.',
      details: <String, Object?>{'query': query, 'pageSize': pageSize},
    );
    return _requestArticles(
      path: '/everything',
      queryParameters: {
        'q': query,
        'language': 'de',
        'searchIn': 'title,description',
        'sortBy': 'publishedAt',
        'pageSize': '$pageSize',
      },
    );
  }

  Future<List<NewsArticle>> _requestArticles({
    required String path,
    required Map<String, String> queryParameters,
  }) async {
    if (!NewsApiConfig.hasKey) {
      throw const NewsApiException('News API 키가 설정되지 않았습니다.');
    }

    final uri = Uri.parse(
      '${NewsApiConfig.baseUrl}$path',
    ).replace(queryParameters: queryParameters);

    AppLogger.info(
      'NewsApiClient',
      'Sending http request.',
      details: <String, Object?>{'url': uri.toString()},
    );

    final response = await _httpClient.get(uri, headers: {
      'X-Api-Key': NewsApiConfig.apiKey,
    });

    if (response.statusCode != 200) {
      AppLogger.warn(
        'NewsApiClient',
        'News api request failed.',
        details: <String, Object?>{
          'url': uri.toString(),
          'statusCode': response.statusCode,
        },
      );
      throw NewsApiException('뉴스를 불러오지 못했습니다. (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const NewsApiException('알 수 없는 뉴스 응답 형식입니다.');
    }

    if (decoded['status'] != 'ok') {
      final message = decoded['message']?.toString();
      throw NewsApiException(message ?? 'News API 요청에 실패했습니다.');
    }

    final articles = decoded['articles'];
    if (articles is! List) {
      return const <NewsArticle>[];
    }

    final parsedArticles = articles
        .whereType<Map<String, dynamic>>()
        .map(NewsArticle.fromJson)
        .where((article) => article.url.trim().isNotEmpty)
        .toList();

    AppLogger.info(
      'NewsApiClient',
      'News api response parsed.',
      details: <String, Object?>{
        'url': uri.toString(),
        'articleCount': parsedArticles.length,
      },
    );
    return parsedArticles;
  }
}

class NewsApiException implements Exception {
  const NewsApiException(this.message);

  final String message;

  @override
  String toString() => 'NewsApiException: $message';
}
