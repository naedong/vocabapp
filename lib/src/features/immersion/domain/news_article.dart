import 'article_text_cleaner.dart';

class NewsArticle {
  const NewsArticle({
    required this.title,
    required this.description,
    required this.sourceName,
    required this.url,
    required this.publishedAt,
    this.imageUrl,
    this.content,
    this.isContentTruncated = false,
  });

  final String title;
  final String description;
  final String sourceName;
  final String url;
  final DateTime? publishedAt;
  final String? imageUrl;
  final String? content;
  final bool isContentTruncated;

  bool get requiresSourceEnrichment {
    final cleanedBody = content?.trim() ?? '';
    return isContentTruncated || cleanedBody.isEmpty || cleanedBody.length < 420;
  }

  String get readingScript {
    return buildReadingScript();
  }

  String buildReadingScript({String? bodyOverride}) {
    return buildArticleReadingScript(
      title: title,
      description: description,
      body: bodyOverride ?? content,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'description': description,
      'source': {'name': sourceName},
      'url': url,
      'publishedAt': publishedAt?.toIso8601String(),
      'urlToImage': imageUrl,
      'content': content,
      'isContentTruncated': isContentTruncated,
    };
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    final publishedRaw = json['publishedAt']?.toString();
    final rawContent = json['content']?.toString();

    return NewsArticle(
      title: sanitizeArticleTitle(json['title']?.toString() ?? ''),
      description: sanitizeArticlePreview(
        json['description']?.toString(),
        fallbackBody: rawContent,
      ),
      sourceName: source is Map<String, dynamic>
          ? source['name']?.toString() ?? '출처 미상'
          : '출처 미상',
      url: json['url']?.toString() ?? '',
      publishedAt: publishedRaw == null || publishedRaw.isEmpty
          ? null
          : DateTime.tryParse(publishedRaw),
      imageUrl: json['urlToImage']?.toString(),
      content: sanitizeArticleBody(rawContent),
      isContentTruncated:
          json['isContentTruncated'] == true ||
          looksLikeTruncatedArticle(rawContent),
    );
  }
}
