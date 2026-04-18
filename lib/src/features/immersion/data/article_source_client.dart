import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/logging/app_logger.dart';
import '../domain/article_text_cleaner.dart';

class ArticleSourceClient {
  ArticleSourceClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  void dispose() {
    _httpClient.close();
  }

  Future<String?> fetchReadableBody(String url) async {
    if (kIsWeb) {
      AppLogger.info(
        'ArticleSourceClient',
        'Skip source fetch on web because the browser may block cross-origin article pages.',
        details: <String, Object?>{'url': url},
      );
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppLogger.warn(
        'ArticleSourceClient',
        'Source url is invalid.',
        details: <String, Object?>{'url': url},
      );
      return null;
    }

    try {
      AppLogger.info(
        'ArticleSourceClient',
        'Fetching article source body.',
        details: <String, Object?>{'url': url},
      );

      final response = await _httpClient.get(
        uri,
        headers: const <String, String>{
          'Accept': 'text/html,application/xhtml+xml',
          'User-Agent':
              'Mozilla/5.0 (compatible; DeutschFlow/1.0; +https://newsapi.org)',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        AppLogger.warn(
          'ArticleSourceClient',
          'Source fetch failed.',
          details: <String, Object?>{
            'url': url,
            'statusCode': response.statusCode,
          },
        );
        return null;
      }

      final body = _extractReadableBody(response.body);
      if (body == null || body.isEmpty) {
        AppLogger.warn(
          'ArticleSourceClient',
          'Readable paragraphs were not found in source html.',
          details: <String, Object?>{'url': url},
        );
        return null;
      }

      AppLogger.info(
        'ArticleSourceClient',
        'Source body extracted.',
        details: <String, Object?>{'url': url, 'length': body.length},
      );
      return body;
    } catch (error, stackTrace) {
      AppLogger.error(
        'ArticleSourceClient',
        'Unexpected error while fetching source body.',
        error: error,
        stackTrace: stackTrace,
        details: <String, Object?>{'url': url},
      );
      return null;
    }
  }

  String? _extractReadableBody(String html) {
    final candidates = <String>[
      ...RegExp(
        r'<article[^>]*>([\s\S]*?)</article>',
        caseSensitive: false,
      ).allMatches(html).map((match) => match.group(1) ?? ''),
      ...RegExp(
        r'<main[^>]*>([\s\S]*?)</main>',
        caseSensitive: false,
      ).allMatches(html).map((match) => match.group(1) ?? ''),
      html,
    ];

    for (final candidate in candidates) {
      final paragraphs = RegExp(r'<p[^>]*>([\s\S]*?)</p>', caseSensitive: false)
          .allMatches(candidate)
          .map((match) {
            return sanitizeArticleBody(match.group(1));
          })
          .where((paragraph) => paragraph.isNotEmpty)
          .toList();

      final joined = paragraphs.join('\n\n').trim();
      if (joined.length >= 450) {
        return joined;
      }
    }

    final bodyMatch = RegExp(
      r'<body[^>]*>([\s\S]*?)</body>',
      caseSensitive: false,
    ).firstMatch(html);
    final plainBody = sanitizeArticleBody(
      stripHtmlToText(bodyMatch?.group(1) ?? html),
    );
    return plainBody.length >= 450 ? plainBody : null;
  }
}
