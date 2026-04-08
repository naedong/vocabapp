class ScriptToken {
  const ScriptToken({
    required this.surface,
    required this.normalized,
    required this.isWord,
  });

  final String surface;
  final String normalized;
  final bool isWord;
}

class GrammarInsight {
  const GrammarInsight({
    required this.id,
    required this.title,
    required this.explanation,
    required this.snippet,
  });

  final String id;
  final String title;
  final String explanation;
  final String snippet;
}

class ScriptAnalyzer {
  const ScriptAnalyzer._();

  static List<List<ScriptToken>> tokenizeParagraphs(String script) {
    final paragraphs = script
        .split(RegExp(r'\n\s*\n'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty);

    return [for (final paragraph in paragraphs) _tokenize(paragraph)];
  }

  static List<GrammarInsight> detectGrammarInsights(String script) {
    final normalizedScript = script.trim();
    if (normalizedScript.isEmpty) {
      return const <GrammarInsight>[];
    }

    final insights = <GrammarInsight>[];
    final seen = <String>{};

    for (final pattern in _grammarPatterns) {
      final matches = pattern.regex.allMatches(normalizedScript).take(3);
      for (final match in matches) {
        final snippet = _snippetAroundMatch(normalizedScript, match);
        final key = '${pattern.id}::$snippet';
        if (seen.add(key)) {
          insights.add(
            GrammarInsight(
              id: pattern.id,
              title: pattern.title,
              explanation: pattern.explanation,
              snippet: snippet,
            ),
          );
        }
      }
    }

    return insights;
  }

  static String normalizeWord(String token) {
    return token
        .toLowerCase()
        .replaceAll(RegExp(r'^[^A-Za-zÄÖÜäöüß]+'), '')
        .replaceAll(RegExp(r'[^A-Za-zÄÖÜäöüß]+$'), '');
  }

  static List<ScriptToken> _tokenize(String paragraph) {
    final regex = RegExp(
      r"[A-Za-zÄÖÜäöüß]+(?:-[A-Za-zÄÖÜäöüß]+)*|[0-9]+|[^\s]",
    );
    return regex.allMatches(paragraph).map((match) {
      final surface = match.group(0) ?? '';
      final normalized = normalizeWord(surface);
      final isWord = normalized.isNotEmpty;
      return ScriptToken(
        surface: surface,
        normalized: normalized,
        isWord: isWord,
      );
    }).toList();
  }

  static String _snippetAroundMatch(String text, RegExpMatch match) {
    final start = (match.start - 32).clamp(0, text.length);
    final end = (match.end + 48).clamp(0, text.length);
    return text.substring(start, end).replaceAll('\n', ' ').trim();
  }
}

class _GrammarPattern {
  const _GrammarPattern({
    required this.id,
    required this.regex,
    required this.title,
    required this.explanation,
  });

  final String id;
  final RegExp regex;
  final String title;
  final String explanation;
}

final List<_GrammarPattern> _grammarPatterns = [
  _GrammarPattern(
    id: 'subordinate-clause',
    regex: RegExp(
      r'\b(weil|dass|wenn|obwohl|damit|bevor|nachdem)\b',
      caseSensitive: false,
    ),
    title: '종속절 연결어',
    explanation:
        'weil, dass, wenn 같은 접속사는 문장을 종속절로 끌고 가며 독일어에서는 동사가 뒤로 밀리는 경우가 많습니다.',
  ),
  _GrammarPattern(
    id: 'modal-verbs',
    regex: RegExp(
      r'\b(kann|koennen|können|muss|muessen|müssen|will|wollen|darf|duerfen|dürfen|soll|sollen|mag|moegen|mögen)\b',
      caseSensitive: false,
    ),
    title: '화법조동사',
    explanation:
        'können, müssen, wollen 같은 조동사는 의미를 바꾸고 본동사를 문장 끝 부정사로 보내는 핵심 패턴입니다.',
  ),
  _GrammarPattern(
    id: 'perfekt',
    regex: RegExp(
      r'\b(habe|hast|hat|haben|habt|bin|bist|ist|sind|seid)\b.{0,40}\b(ge\w+(t|en)|\w+iert)\b',
      caseSensitive: false,
    ),
    title: 'Perfekt 완료 시제',
    explanation: 'haben/sein과 과거분사가 함께 나오면 회화에서 자주 쓰이는 완료 시제일 가능성이 큽니다.',
  ),
  _GrammarPattern(
    id: 'zu-infinitive',
    regex: RegExp(r'\bzu\s+[A-Za-zÄÖÜäöüß]+en\b', caseSensitive: false),
    title: 'zu 부정사',
    explanation: 'zu + 동사원형은 영어의 to부정사처럼 목적이나 계획, 의도를 표현할 때 자주 나옵니다.',
  ),
];
