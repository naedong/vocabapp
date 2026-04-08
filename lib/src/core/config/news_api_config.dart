import 'news_api_secrets.dart' as secrets;

class NewsApiConfig {
  const NewsApiConfig._();

  static const String baseUrl = 'https://newsapi.org/v2';

  static String get apiKey {
    const fromEnvironment = String.fromEnvironment('NEWS_API_KEY');
    if (fromEnvironment.isNotEmpty) {
      return fromEnvironment;
    }

    return secrets.newsApiKey;
  }

  static bool get hasKey => apiKey.trim().isNotEmpty;
}
