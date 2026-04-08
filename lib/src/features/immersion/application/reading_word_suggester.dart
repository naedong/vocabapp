import '../../../core/audio/voice_locale.dart';
import '../../../core/database/app_database.dart';
import '../../study/application/study_word_draft.dart';
import 'script_analyzer.dart';

class ReadingWordSuggestion {
  const ReadingWordSuggestion({
    required this.meaningKo,
    required this.meaningEn,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.grammarHint,
    required this.sourceLabel,
    required this.isApproximate,
    this.article,
    this.ttsLocale = defaultVoiceLocaleCode,
    this.deck = '실전 읽기',
  });

  final String meaningKo;
  final String meaningEn;
  final String pronunciation;
  final String partOfSpeech;
  final String grammarHint;
  final String sourceLabel;
  final bool isApproximate;
  final String? article;
  final String ttsLocale;
  final String deck;

  StudyWordDraft toStudyWordDraft({
    required String german,
    required String contextSnippet,
    String? meaningKoOverride,
  }) {
    final resolvedMeaningKo = (meaningKoOverride ?? meaningKo).trim().isEmpty
        ? meaningKo
        : (meaningKoOverride ?? meaningKo).trim();
    return StudyWordDraft(
      german: german,
      meaningEn: meaningEn,
      meaningKo: resolvedMeaningKo,
      pronunciation: pronunciation,
      partOfSpeech: partOfSpeech,
      article: article,
      exampleSentence: contextSnippet,
      exampleTranslation: resolvedMeaningKo,
      deck: deck,
      ttsLocale: ttsLocale,
    );
  }
}

class ReadingWordSuggester {
  const ReadingWordSuggester._();

  static ReadingWordSuggestion suggest({
    required ScriptToken token,
    required List<VocabWord> knownMatches,
  }) {
    if (knownMatches.isNotEmpty) {
      final word = knownMatches.first;
      return ReadingWordSuggestion(
        meaningKo: word.meaningKo,
        meaningEn: word.meaningEn,
        pronunciation: word.pronunciation.trim().isEmpty
            ? token.surface
            : word.pronunciation,
        partOfSpeech: word.partOfSpeech,
        article: word.article,
        grammarHint: _grammarHintForKnownWord(word),
        sourceLabel: '내 단어장',
        isApproximate: false,
        deck: word.deck,
        ttsLocale: word.ttsLocale,
      );
    }

    final builtIn = _builtinLexicon[token.normalized.toLowerCase()];
    if (builtIn != null) {
      return ReadingWordSuggestion(
        meaningKo: builtIn.meaningKo,
        meaningEn: builtIn.meaningEn,
        pronunciation: token.surface,
        partOfSpeech: builtIn.partOfSpeech,
        grammarHint: builtIn.grammarHint,
        sourceLabel: '기본 독일어 사전',
        isApproximate: false,
      );
    }

    final guessedPartOfSpeech = _guessPartOfSpeech(token);
    return ReadingWordSuggestion(
      meaningKo: '뜻을 확인해 보세요',
      meaningEn: 'Check meaning',
      pronunciation: token.surface,
      partOfSpeech: guessedPartOfSpeech,
      grammarHint: _fallbackGrammarHint(guessedPartOfSpeech),
      sourceLabel: '형태 기반 자동 추정',
      isApproximate: true,
    );
  }

  static String _guessPartOfSpeech(ScriptToken token) {
    final normalized = token.normalized.toLowerCase();
    if (normalized.endsWith('en')) {
      return 'verb';
    }
    if (normalized.endsWith('lich') ||
        normalized.endsWith('ig') ||
        normalized.endsWith('isch')) {
      return 'adjective';
    }
    if (token.surface.isNotEmpty &&
        token.surface[0] == token.surface[0].toUpperCase()) {
      return 'noun';
    }
    return 'expression';
  }

  static String _fallbackGrammarHint(String partOfSpeech) {
    switch (partOfSpeech) {
      case 'noun':
        return '독일어 명사는 보통 첫 글자를 대문자로 쓰고, 관사와 함께 익히면 성과 격 변화를 기억하기 좋습니다.';
      case 'verb':
        return '동사는 인칭과 시제에 따라 어미가 바뀌므로 원형과 함께 현재형 예문을 같이 보며 외우는 편이 좋습니다.';
      case 'adjective':
        return '형용사는 문장 안에서 서술적으로도 쓰이고, 명사 앞에 올 때는 어미 변화가 생길 수 있습니다.';
      default:
        return '문맥 안에서 자주 함께 나오는 단어와 같이 익히면 실제 사용 감각을 더 빨리 만들 수 있습니다.';
    }
  }

  static String _grammarHintForKnownWord(VocabWord word) {
    final part = word.partOfSpeech.toLowerCase();
    if (part.contains('noun')) {
      return '${word.german}는 명사로 보입니다. 관사와 함께 외우면 독일어의 성과 격 변화를 같이 익힐 수 있습니다.';
    }
    if (part.contains('verb')) {
      return '${word.german}는 동사로 보입니다. 현재형 변화와 함께 예문을 반복해서 보면 실제로 쓰기 쉬워집니다.';
    }
    if (part.contains('adjective')) {
      return '${word.german}는 형용사로 보입니다. 명사를 꾸밀 때와 서술어로 쓸 때의 차이를 같이 보세요.';
    }
    return '${word.german}는 ${word.partOfSpeech} 계열 표현입니다. 문장 단위로 익히면 활용하기 좋습니다.';
  }
}

class _BuiltinLexiconEntry {
  const _BuiltinLexiconEntry({
    required this.meaningKo,
    required this.meaningEn,
    required this.partOfSpeech,
    required this.grammarHint,
  });

  final String meaningKo;
  final String meaningEn;
  final String partOfSpeech;
  final String grammarHint;
}

const Map<String, _BuiltinLexiconEntry>
_builtinLexicon = <String, _BuiltinLexiconEntry>{
  'der': _BuiltinLexiconEntry(
    meaningKo: '그, 남성 명사의 정관사',
    meaningEn: 'the (masculine article)',
    partOfSpeech: 'article',
    grammarHint:
        'der는 남성 명사의 기본형 정관사입니다. 격이 바뀌면 den, dem, des 같은 형태로 달라질 수 있습니다.',
  ),
  'die': _BuiltinLexiconEntry(
    meaningKo: '그, 여성 명사의 정관사 / 복수 정관사',
    meaningEn: 'the (feminine article / plural)',
    partOfSpeech: 'article',
    grammarHint:
        'die는 여성 명사 단수나 복수 명사에 자주 쓰입니다. 문맥에 따라 성과 수를 같이 확인하는 것이 중요합니다.',
  ),
  'das': _BuiltinLexiconEntry(
    meaningKo: '그, 중성 명사의 정관사',
    meaningEn: 'the (neuter article)',
    partOfSpeech: 'article',
    grammarHint: 'das는 중성 명사의 정관사입니다. 접속사 dass와 철자가 비슷하므로 문장 기능을 구분해 보세요.',
  ),
  'ein': _BuiltinLexiconEntry(
    meaningKo: '하나의, 어떤',
    meaningEn: 'a, an',
    partOfSpeech: 'article',
    grammarHint:
        'ein은 부정관사입니다. 뒤따르는 명사의 성과 격에 따라 eine, einen, einem처럼 형태가 바뀝니다.',
  ),
  'eine': _BuiltinLexiconEntry(
    meaningKo: '하나의, 어떤',
    meaningEn: 'a, an',
    partOfSpeech: 'article',
    grammarHint: 'eine는 여성 명사와 자주 쓰이는 부정관사 형태입니다. 관사 자체도 문법 정보이므로 함께 외우면 좋습니다.',
  ),
  'ich': _BuiltinLexiconEntry(
    meaningKo: '나',
    meaningEn: 'I',
    partOfSpeech: 'pronoun',
    grammarHint: 'ich는 1인칭 단수 주격입니다. 목적격에서는 mich, 여격에서는 mir로 바뀝니다.',
  ),
  'du': _BuiltinLexiconEntry(
    meaningKo: '너',
    meaningEn: 'you',
    partOfSpeech: 'pronoun',
    grammarHint: 'du는 2인칭 단수 주격입니다. 동사 변화도 du형으로 함께 외우면 말하기가 빨라집니다.',
  ),
  'wir': _BuiltinLexiconEntry(
    meaningKo: '우리',
    meaningEn: 'we',
    partOfSpeech: 'pronoun',
    grammarHint: 'wir는 1인칭 복수 주격입니다. 현재형 동사는 보통 원형과 같은 어미를 쓰는 경우가 많습니다.',
  ),
  'sie': _BuiltinLexiconEntry(
    meaningKo: '그녀 / 그들 / 당신들',
    meaningEn: 'she / they / you',
    partOfSpeech: 'pronoun',
    grammarHint:
        'sie는 문맥에 따라 그녀, 그들, 공손한 당신으로 해석될 수 있습니다. 동사 변화와 대문자 여부를 같이 보세요.',
  ),
  'ist': _BuiltinLexiconEntry(
    meaningKo: '이다, 있다',
    meaningEn: 'is',
    partOfSpeech: 'verb',
    grammarHint: 'ist는 sein 동사의 3인칭 단수 현재형입니다. 상태나 존재를 설명할 때 아주 자주 나옵니다.',
  ),
  'sind': _BuiltinLexiconEntry(
    meaningKo: '이다, 있다',
    meaningEn: 'are',
    partOfSpeech: 'verb',
    grammarHint:
        'sind는 sein 동사의 복수형 또는 공손형 현재형입니다. 주어에 따라 bin, bist, ist, seid와 구분해 보세요.',
  ),
  'war': _BuiltinLexiconEntry(
    meaningKo: '이었다, 있었다',
    meaningEn: 'was',
    partOfSpeech: 'verb',
    grammarHint: 'war는 sein 동사의 과거형입니다. 기사나 스토리 문장에서는 상태를 회상할 때 자주 보입니다.',
  ),
  'habe': _BuiltinLexiconEntry(
    meaningKo: '가지고 있다 / 완료 시제 조동사',
    meaningEn: 'have',
    partOfSpeech: 'verb',
    grammarHint:
        'habe는 haben 동사의 1인칭 형태이면서 완료 시제 조동사로도 자주 쓰입니다. 뒤에 과거분사가 오는지 확인해 보세요.',
  ),
  'hat': _BuiltinLexiconEntry(
    meaningKo: '가지고 있다 / 완료 시제 조동사',
    meaningEn: 'has',
    partOfSpeech: 'verb',
    grammarHint: 'hat은 haben 동사의 3인칭 단수형입니다. 과거분사와 함께 나오면 Perfekt일 가능성이 큽니다.',
  ),
  'kann': _BuiltinLexiconEntry(
    meaningKo: '할 수 있다',
    meaningEn: 'can',
    partOfSpeech: 'modal verb',
    grammarHint: 'kann은 화법조동사 koennen의 활용형입니다. 본동사는 보통 문장 끝 원형으로 갑니다.',
  ),
  'muss': _BuiltinLexiconEntry(
    meaningKo: '해야 한다',
    meaningEn: 'must',
    partOfSpeech: 'modal verb',
    grammarHint: 'muss는 필요나 의무를 나타내는 조동사입니다. 뒤에 본동사 원형이 뒤따르는 구조를 같이 보세요.',
  ),
  'will': _BuiltinLexiconEntry(
    meaningKo: '원한다',
    meaningEn: 'wants to',
    partOfSpeech: 'modal verb',
    grammarHint: 'will은 wollen의 활용형입니다. 의도나 계획을 말할 때 자주 쓰이고, 뒤 동사는 원형으로 갑니다.',
  ),
  'mit': _BuiltinLexiconEntry(
    meaningKo: '함께, ~와',
    meaningEn: 'with',
    partOfSpeech: 'preposition',
    grammarHint: 'mit는 여격을 요구하는 전치사입니다. 뒤 명사의 형태가 바뀌는지 같이 확인해 보세요.',
  ),
  'für': _BuiltinLexiconEntry(
    meaningKo: '~를 위해, ~에 대해',
    meaningEn: 'for',
    partOfSpeech: 'preposition',
    grammarHint: 'fuer는 대체로 대격을 요구하는 전치사입니다. 전치사마다 뒤에 오는 격이 다르다는 점이 중요합니다.',
  ),
  'in': _BuiltinLexiconEntry(
    meaningKo: '~안에, ~에서',
    meaningEn: 'in',
    partOfSpeech: 'preposition',
    grammarHint: 'in은 위치와 방향에 따라 여격 또는 대격이 될 수 있는 대표적인 이중격 전치사입니다.',
  ),
  'auf': _BuiltinLexiconEntry(
    meaningKo: '~위에, ~로',
    meaningEn: 'on, onto',
    partOfSpeech: 'preposition',
    grammarHint: 'auf도 위치/방향에 따라 격이 달라질 수 있습니다. 문장 속 움직임이 있는지 같이 보세요.',
  ),
  'zu': _BuiltinLexiconEntry(
    meaningKo: '~로, ~에게 / zu 부정사 표지',
    meaningEn: 'to / infinitive marker',
    partOfSpeech: 'preposition',
    grammarHint:
        'zu는 전치사로도 쓰이고 동사 앞에 붙어 zu부정사를 만들기도 합니다. 뒤 구조를 함께 보면 구분이 쉽습니다.',
  ),
  'weil': _BuiltinLexiconEntry(
    meaningKo: '~왜냐하면, ~때문에',
    meaningEn: 'because',
    partOfSpeech: 'conjunction',
    grammarHint: 'weil은 종속절을 여는 접속사라서 뒤 절에서는 동사가 뒤로 밀리는 경우가 많습니다.',
  ),
  'dass': _BuiltinLexiconEntry(
    meaningKo: '~라는 것, ~라고',
    meaningEn: 'that',
    partOfSpeech: 'conjunction',
    grammarHint: 'dass는 종속절을 이끄는 접속사입니다. 철자가 das와 비슷하지만 문장 역할이 다릅니다.',
  ),
  'wenn': _BuiltinLexiconEntry(
    meaningKo: '만약 ~하면 / ~할 때',
    meaningEn: 'if, when',
    partOfSpeech: 'conjunction',
    grammarHint: 'wenn은 조건이나 반복되는 시점을 말할 때 자주 쓰이며, 종속절 어순을 만듭니다.',
  ),
  'heute': _BuiltinLexiconEntry(
    meaningKo: '오늘',
    meaningEn: 'today',
    partOfSpeech: 'adverb',
    grammarHint: 'heute는 시간을 나타내는 부사입니다. 문장 첫머리에 오면 동사 위치가 바로 뒤로 오는 점도 같이 보세요.',
  ),
  'morgen': _BuiltinLexiconEntry(
    meaningKo: '내일 / 아침',
    meaningEn: 'tomorrow / morning',
    partOfSpeech: 'adverb',
    grammarHint: 'morgen은 시간 부사이면서 명사로도 쓰일 수 있습니다. 대문자 여부와 문맥으로 구분해 보세요.',
  ),
};
