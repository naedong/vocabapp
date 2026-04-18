import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_app/src/app/responsive_layout.dart';
import 'package:vocab_app/src/core/audio/voice_locale.dart';
import 'package:vocab_app/src/core/audio/pronunciation_scoring.dart';
import 'package:vocab_app/src/core/database/app_database.dart';
import 'package:vocab_app/src/core/settings/app_settings.dart';
import 'package:vocab_app/src/features/dictionary/domain/dictionary_lookup.dart';
import 'package:vocab_app/src/features/study/application/daily_word_recommendation_service.dart';
import 'package:vocab_app/src/features/study/application/practice_exam_catalog.dart';
import 'package:vocab_app/src/features/study/application/study_repository.dart';

void main() {
  test('추천 단어를 저장하면 문법 메모와 날짜 키가 함께 저장된다', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.addWord(
      languageCode: 'de',
      german: 'Rechnung',
      article: 'die',
      meaningEn: 'bill',
      meaningKo: '계산서',
      pronunciation: '/ˈʁɛçnʊŋ/',
      ttsLocale: 'de-DE',
      partOfSpeech: 'noun',
      exampleSentence: 'Kann ich bitte die Rechnung bekommen?',
      exampleTranslation: '계산서 좀 받을 수 있을까요?',
      deck: '오늘의 추천',
      grammarNote: '명사는 die와 함께 외우면 여성 명사라는 점을 같이 기억하기 좋습니다.',
      isDailyRecommendation: true,
      dailyRecommendationDate: DateTime(2026, 4, 10),
    );

    final words = await database.select(database.vocabWords).get();
    expect(words, hasLength(1));
    expect(words.single.german, 'Rechnung');
    expect(words.single.grammarNote, contains('여성 명사'));
    expect(words.single.isDailyRecommendation, isTrue);
    expect(words.single.dailyRecommendationDateKey, '2026-04-10');
  });

  test('일일 추천 서비스는 부족한 개수만 형태변화 메모와 함께 만든다', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.addWord(
      languageCode: 'de',
      german: 'Rechnung',
      article: 'die',
      meaningEn: 'bill',
      meaningKo: '계산서',
      pronunciation: '/ˈʁɛçnʊŋ/',
      ttsLocale: 'de-DE',
      partOfSpeech: 'noun',
      exampleSentence: 'Kann ich bitte die Rechnung bekommen?',
      exampleTranslation: '계산서 좀 받을 수 있을까요?',
      deck: 'Daily Picks',
      grammarNote: '형태변화: die Rechnung, die Rechnungen',
      isDailyRecommendation: true,
      dailyRecommendationDate: DateTime(2026, 4, 10),
    );

    final service = DailyGermanRecommendationService.withLookup((
      word, {
      contextSnippet,
      forceRefresh = false,
      preference = AiProviderPreference.auto,
    }) async {
      return DictionaryAutoFill(
        word: word,
        meaningKo: '검증된 뜻',
        meaningEn: 'verified meaning',
        pronunciation: word,
        partOfSpeech: 'verb',
        article: null,
        exampleSentence: contextSnippet ?? '$word ist nuetzlich.',
        exampleTranslation: '검증된 예문 번역',
        sourceLabel: 'Gemini autofill',
        sourceUrl: 'https://ai.google.dev/',
        licenseName: 'Gemini',
        licenseUrl: 'https://ai.google.dev/',
        forms: const ['ich pruefe', 'du pruefst', 'geprueft'],
        synonyms: const <String>[],
        grammarNotes: const ['Gemini가 만든 문법 메모'],
        usedDefinitionFallbackForKo: false,
        usedDefinitionFallbackForEn: false,
        ttsLocale: 'en-US',
      );
    });

    final savedWords = await database.select(database.vocabWords).get();
    final recommendations = await service.buildRecommendations(
      date: DateTime(2026, 4, 10),
      savedWords: savedWords,
      targetCount: 3,
    );

    expect(recommendations, hasLength(2));
    expect(recommendations.first.grammarNote, contains('형태변화'));
    expect(recommendations.first.grammarNote, contains('Gemini autofill'));
    expect(recommendations.first.meaningKo, '검증된 뜻');
    expect(recommendations.first.ttsLocale, 'de-DE');
  });

  test('저장된 단어의 TTS locale을 독일어 음성으로 바꿀 수 있다', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = StudyRepository(database);
    addTearDown(database.close);

    await database.addWord(
      languageCode: 'de',
      german: 'Entscheidung',
      article: 'die',
      meaningEn: 'decision',
      meaningKo: '결정',
      pronunciation: '엔트샤이둥',
      ttsLocale: 'en-US',
      partOfSpeech: 'noun',
      exampleSentence: 'Die Entscheidung fällt mir heute leichter.',
      exampleTranslation: '오늘은 그 결정을 내리기가 더 쉽다.',
      deck: 'Daily Picks',
      grammarNote: '형태변화: die Entscheidung, die Entscheidungen',
      isDailyRecommendation: true,
      dailyRecommendationDate: DateTime(2026, 4, 10),
    );

    final word = (await database.select(database.vocabWords).get()).single;
    await repository.updateWordTtsLocale(word, 'de-AT');

    final updated = (await database.select(database.vocabWords).get()).single;
    expect(updated.ttsLocale, 'de-AT');
  });

  test('독일어 단어는 영어 TTS locale을 독일어 기본값으로 보정한다', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = StudyRepository(database);
    addTearDown(database.close);

    expect(
      voiceLocaleForLanguageCode(languageCode: 'de', requestedLocale: 'en-US'),
      'de-DE',
    );
    expect(
      voiceLocaleForLanguageCode(languageCode: 'de', requestedLocale: 'de-AT'),
      'de-AT',
    );

    await database.addWord(
      languageCode: 'de',
      german: 'Verantwortung',
      article: 'die',
      meaningEn: 'responsibility',
      meaningKo: '책임',
      pronunciation: '페어안트보어퉁',
      ttsLocale: 'en-US',
      partOfSpeech: 'noun',
      exampleSentence: 'Ich übernehme die Verantwortung.',
      exampleTranslation: '나는 책임을 맡는다.',
      deck: 'Daily Picks',
    );

    final word = (await database.select(database.vocabWords).get()).single;
    expect(word.ttsLocale, 'de-DE');

    await repository.updateWordTtsLocale(word, 'en-GB');
    final updated = (await database.select(database.vocabWords).get()).single;
    expect(updated.ttsLocale, 'de-DE');
  });

  test('문제 세트는 정답 기록 없이 복습 선반에 저장된다', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = StudyRepository(database);
    addTearDown(database.close);

    final set = builtInGermanPracticeExamSets.first;

    final inserted = await repository.savePracticeExamSet(set);
    expect(inserted, isTrue);

    final savedSets = await repository
        .watchSavedPracticeExamSets(languageCode: 'de')
        .first;
    expect(savedSets, hasLength(1));
    expect(savedSets.single.set.sourceKey, set.sourceKey);
    expect(
      savedSets.single.set.questions.first.prompt,
      set.questions.first.prompt,
    );

    final duplicateInsert = await repository.savePracticeExamSet(set);
    expect(duplicateInsert, isFalse);

    final dedupedSets = await repository
        .watchSavedPracticeExamSets(languageCode: 'de')
        .first;
    expect(dedupedSets, hasLength(1));
  });

  group('ResponsiveLayout', () {
    test('compact width uses phone-sized spacing', () {
      final layout = ResponsiveLayout.fromWidth(390);

      expect(layout.isCompact, isTrue);
      expect(layout.pagePadding, 16);
      expect(layout.cardPadding, 18);
      expect(layout.columnsFor(minTileWidth: 210), 1);
    });

    test('tablet width keeps readable max width and multi-column cards', () {
      final layout = ResponsiveLayout.fromWidth(820);

      expect(layout.isTablet, isTrue);
      expect(layout.isExpanded, isFalse);
      expect(layout.pagePadding, 24);
      expect(layout.maxReadableWidth, 920);
      expect(layout.columnsFor(minTileWidth: 210), 3);
    });

    test('expanded width enables desktop density', () {
      final layout = ResponsiveLayout.fromWidth(1280);

      expect(layout.isExpanded, isTrue);
      expect(layout.panelRadius, 34);
      expect(layout.displayTitleSize, 34);
      expect(layout.columnsFor(minTileWidth: 210), 4);
    });
  });

  group('scorePronunciationAttempt', () {
    test('matches an exact transcript strongly', () {
      final result = scorePronunciationAttempt(
        targetText: 'Rechnung',
        heardText: 'Rechnung',
      );

      expect(result.percentScore, 100);
      expect(result.band, PronunciationScoreBand.excellent);
    });

    test('accepts transcripts that include an article', () {
      final result = scorePronunciationAttempt(
        targetText: 'Rechnung',
        heardText: 'die Rechnung',
      );

      expect(result.percentScore, greaterThanOrEqualTo(90));
    });

    test('normalizes german umlaut spellings for comparison', () {
      final result = scorePronunciationAttempt(
        targetText: 'Gespraech',
        heardText: 'Gespräch',
      );

      expect(result.percentScore, 100);
      expect(normalizePronunciationComparison('Fußgänger'), 'fussgaenger');
    });
  });
}
