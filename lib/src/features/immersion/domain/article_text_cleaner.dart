String sanitizeArticleTitle(String rawTitle) {
  final cleaned = _cleanPlainText(rawTitle, keepParagraphs: false);
  return cleaned.isEmpty ? '제목 없음' : cleaned;
}

String sanitizeArticlePreview(
  String? rawPreview, {
  String? fallbackBody,
}) {
  final cleanedPreview = _cleanPlainText(rawPreview ?? '', keepParagraphs: false);
  if (cleanedPreview.isNotEmpty) {
    return cleanedPreview;
  }

  final cleanedBody = sanitizeArticleBody(fallbackBody);
  if (cleanedBody.isEmpty) {
    return '요약 정보가 없는 기사입니다.';
  }

  final sentences = RegExp(
    r'[^.!?]+[.!?]?',
  ).allMatches(cleanedBody).map((match) {
    return (match.group(0) ?? '').trim();
  }).where((sentence) => sentence.isNotEmpty).take(2).toList();

  if (sentences.isNotEmpty) {
    return sentences.join(' ');
  }

  return cleanedBody.length <= 180
      ? cleanedBody
      : '${cleanedBody.substring(0, 180).trim()}...';
}

String sanitizeArticleBody(String? rawBody) {
  final cleaned = _cleanPlainText(rawBody ?? '', keepParagraphs: true);
  if (cleaned.isEmpty) {
    return '';
  }

  final paragraphs = cleaned
      .split('\n')
      .map((paragraph) => paragraph.trim())
      .where(_looksLikeUsefulParagraph)
      .toList();

  return _dedupeParagraphs(paragraphs).join('\n\n').trim();
}

bool looksLikeTruncatedArticle(String? rawBody) {
  if (rawBody == null) {
    return false;
  }

  return RegExp(r'\[\+\d+\s+chars\]$', caseSensitive: false).hasMatch(
    rawBody.trim(),
  );
}

String buildArticleReadingScript({
  required String title,
  required String description,
  String? body,
}) {
  final parts = _dedupeParagraphs([
    sanitizeArticleTitle(title),
    sanitizeArticlePreview(description, fallbackBody: body),
    sanitizeArticleBody(body),
  ]);

  return parts.join('\n\n').trim();
}

String stripHtmlToText(String html, {bool keepParagraphs = true}) {
  var text = html
      .replaceAll(
        RegExp(
          r'<script[^>]*>[\s\S]*?</script>',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(
        RegExp(
          r'<style[^>]*>[\s\S]*?</style>',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(
        RegExp(
          r'<noscript[^>]*>[\s\S]*?</noscript>',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(
        RegExp(
          r'<svg[^>]*>[\s\S]*?</svg>',
          caseSensitive: false,
        ),
        ' ',
      )
      .replaceAll(
        RegExp(r'<br\s*/?>', caseSensitive: false),
        keepParagraphs ? '\n' : ' ',
      )
      .replaceAll(
        RegExp(
          r'</(p|div|section|article|li|h[1-6]|blockquote)>',
          caseSensitive: false,
        ),
        keepParagraphs ? '\n' : ' ',
      )
      .replaceAll(RegExp(r'<[^>]+>', caseSensitive: false), ' ');

  return decodeBasicHtmlEntities(text);
}

String decodeBasicHtmlEntities(String input) {
  return input
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', '\'')
      .replaceAll('&apos;', '\'')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&auml;', 'ä')
      .replaceAll('&ouml;', 'ö')
      .replaceAll('&uuml;', 'ü')
      .replaceAll('&Auml;', 'Ä')
      .replaceAll('&Ouml;', 'Ö')
      .replaceAll('&Uuml;', 'Ü')
      .replaceAll('&szlig;', 'ß');
}

String _cleanPlainText(String raw, {required bool keepParagraphs}) {
  var text = decodeBasicHtmlEntities(raw);
  text = stripHtmlToText(text, keepParagraphs: keepParagraphs);
  text = text
      .replaceAll(RegExp(r'\s*\[\+\d+\s+chars\]$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\bread more\b.*$', caseSensitive: false), '')
      .replaceAll(
        RegExp(r'\bcontinue reading\b.*$', caseSensitive: false),
        '',
      )
      .replaceAll(RegExp(r'\u00a0'), ' ');

  if (keepParagraphs) {
    final paragraphs = text
        .split(RegExp(r'\n+'))
        .map((paragraph) => paragraph.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList();
    return paragraphs.join('\n');
  }

  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _looksLikeUsefulParagraph(String paragraph) {
  if (paragraph.length < 35) {
    return false;
  }

  if (!RegExp(r'[A-Za-zÄÖÜäöüß]').hasMatch(paragraph)) {
    return false;
  }

  final lowered = paragraph.toLowerCase();
  const blockedFragments = <String>[
    'cookie',
    'privacy',
    'newsletter',
    'advertisement',
    'share this',
    'all rights reserved',
    'sign up',
  ];

  for (final fragment in blockedFragments) {
    if (lowered.contains(fragment)) {
      return false;
    }
  }

  return true;
}

List<String> _dedupeParagraphs(List<String> parts) {
  final unique = <String>[];
  final fingerprints = <String>{};

  for (final part in parts) {
    final trimmed = part.trim();
    if (trimmed.isEmpty) {
      continue;
    }

    final fingerprint = trimmed.toLowerCase();
    if (fingerprints.add(fingerprint)) {
      unique.add(trimmed);
    }
  }

  return unique;
}
