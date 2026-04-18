import 'dart:math';

import 'package:drift/drift.dart';

import '../audio/voice_locale.dart';
import 'db_connection.dart';

part 'app_database.g.dart';

class VocabWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get languageCode => text().withDefault(const Constant('de'))();
  TextColumn get german => text()();
  TextColumn get article => text().nullable()();
  TextColumn get partOfSpeech =>
      text().withDefault(const Constant('expression'))();
  TextColumn get meaningEn => text()();
  TextColumn get meaningKo => text()();
  TextColumn get pronunciation => text()();
  TextColumn get ttsLocale =>
      text().withDefault(const Constant(defaultVoiceLocaleCode))();
  TextColumn get exampleSentence => text()();
  TextColumn get exampleTranslation => text()();
  TextColumn get grammarNote => text().nullable()();
  TextColumn get deck => text().withDefault(const Constant('Starter'))();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  IntColumn get mastery => integer().withDefault(const Constant(0))();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  IntColumn get timesReviewed => integer().withDefault(const Constant(0))();
  IntColumn get nextReviewAt => integer().nullable()();
  IntColumn get lastReviewedAt => integer().nullable()();
  BoolColumn get isDailyRecommendation =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dailyRecommendationDateKey => text().nullable()();
  IntColumn get createdAt =>
      integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();
}

class StudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studiedAt => integer()();
  IntColumn get reviewedCount => integer().withDefault(const Constant(0))();
  IntColumn get masteredCount => integer().withDefault(const Constant(0))();
  IntColumn get minutesSpent => integer().withDefault(const Constant(0))();
}

class ReadingDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceUrl => text()();
  TextColumn get sourceTitle => text()();
  TextColumn get sourceName => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get scriptText => text()();
  IntColumn get publishedAt => integer().nullable()();
  IntColumn get createdAt =>
      integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();
  IntColumn get updatedAt => integer().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceUrl},
  ];
}

class ReadingNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(ReadingDocuments, #id)();
  TextColumn get noteType => text()();
  TextColumn get surfaceText => text()();
  TextColumn get normalizedText => text().nullable()();
  TextColumn get meaning => text().nullable()();
  TextColumn get explanation => text().nullable()();
  TextColumn get contextSnippet => text().nullable()();
  IntColumn get createdAt =>
      integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();
}

class NewsCacheEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cacheKey => text()();
  TextColumn get payloadJson => text()();
  IntColumn get fetchedAt =>
      integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {cacheKey},
  ];
}

class AppPreferencesEntries extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get appLanguageCode => text().withDefault(const Constant('en'))();
  TextColumn get studyLanguageCode =>
      text().withDefault(const Constant('de'))();
  TextColumn get aiProviderCode => text().withDefault(const Constant('auto'))();
  IntColumn get updatedAt =>
      integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class PracticeExamEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get languageCode => text().withDefault(const Constant('de'))();
  TextColumn get sourceKey => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdAt =>
      integer().clientDefault(() => DateTime.now().millisecondsSinceEpoch)();
  IntColumn get updatedAt => integer().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {languageCode, sourceKey},
  ];
}

@DriftDatabase(
  tables: [
    VocabWords,
    StudySessions,
    ReadingDocuments,
    ReadingNotes,
    NewsCacheEntries,
    AppPreferencesEntries,
    PracticeExamEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(vocabWords, vocabWords.ttsLocale);
      }
      if (from < 3) {
        await m.createTable(readingDocuments);
        await m.createTable(readingNotes);
      }
      if (from < 4) {
        await m.createTable(newsCacheEntries);
      }
      if (from < 5) {
        await m.addColumn(vocabWords, vocabWords.grammarNote);
        await m.addColumn(vocabWords, vocabWords.isDailyRecommendation);
        await m.addColumn(vocabWords, vocabWords.dailyRecommendationDateKey);
      }
      if (from < 6) {
        await m.addColumn(vocabWords, vocabWords.languageCode);
        await m.createTable(appPreferencesEntries);
      }
      if (from < 7) {
        await m.createTable(practiceExamEntries);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      if (details.versionNow >= 2) {
        await customStatement(
          "UPDATE vocab_words SET tts_locale = '$defaultVoiceLocaleCode' "
          "WHERE tts_locale IS NULL OR tts_locale = ''",
        );
      }
      if (details.versionNow >= 6) {
        await customStatement(
          "UPDATE vocab_words SET language_code = 'de' "
          "WHERE language_code IS NULL OR language_code = ''",
        );
        await customStatement(
          "UPDATE vocab_words SET tts_locale = '$defaultVoiceLocaleCode' "
          "WHERE language_code = 'de' AND "
          "(tts_locale IS NULL OR tts_locale = '' OR "
          "lower(substr(replace(tts_locale, '_', '-'), 1, 2)) <> 'de')",
        );
      }
    },
  );

  Future<void> initialize() async {
    await _ensureImmersionTables();
    await _ensureNewsCacheTable();
    await _ensureAppPreferencesTable();
    await _ensurePracticeExamEntriesTable();
    await _ensureAppPreferencesRow();
    await ensureSeedData();
  }

  Stream<List<VocabWord>> watchWords() {
    return select(vocabWords).watch();
  }

  Stream<List<StudySession>> watchStudySessions() {
    return (select(
      studySessions,
    )..orderBy([(table) => OrderingTerm.desc(table.studiedAt)])).watch();
  }

  Stream<List<ReadingNote>> watchReadingNotes(
    int documentId, {
    required String noteType,
  }) {
    return (select(readingNotes)
          ..where(
            (table) =>
                table.documentId.equals(documentId) &
                table.noteType.equals(noteType),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch();
  }

  Stream<AppPreferencesEntry> watchAppPreferences() {
    return (select(appPreferencesEntries)
          ..where((table) => table.id.equals(1))
          ..limit(1))
        .watchSingle();
  }

  Stream<List<PracticeExamEntry>> watchPracticeExamEntries(
    String languageCode,
  ) {
    return (select(practiceExamEntries)
          ..where((table) => table.languageCode.equals(languageCode))
          ..orderBy([
            (table) => OrderingTerm.desc(table.updatedAt),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Future<void> addWord({
    required String languageCode,
    required String german,
    required String meaningEn,
    required String meaningKo,
    required String pronunciation,
    required String ttsLocale,
    String? article,
    required String partOfSpeech,
    required String exampleSentence,
    required String exampleTranslation,
    required String deck,
    String? grammarNote,
    bool isDailyRecommendation = false,
    DateTime? dailyRecommendationDate,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final preparedLanguageCode = languageCode.trim().isEmpty
        ? 'de'
        : languageCode.trim().toLowerCase();
    final preparedTtsLocale = voiceLocaleForLanguageCode(
      languageCode: preparedLanguageCode,
      requestedLocale: ttsLocale,
    );
    final recommendationDate = isDailyRecommendation
        ? (dailyRecommendationDate ?? DateTime.now())
        : null;

    await into(vocabWords).insert(
      VocabWordsCompanion.insert(
        languageCode: Value(preparedLanguageCode),
        german: german.trim(),
        article: _optionalText(article),
        partOfSpeech: partOfSpeech.trim().isEmpty
            ? const Value('expression')
            : Value(partOfSpeech.trim()),
        meaningEn: meaningEn.trim(),
        meaningKo: meaningKo.trim(),
        pronunciation: pronunciation.trim(),
        ttsLocale: Value(preparedTtsLocale),
        exampleSentence: exampleSentence.trim().isEmpty
            ? '${german.trim()} ist ein wichtiges Wort.'
            : exampleSentence.trim(),
        exampleTranslation: exampleTranslation.trim().isEmpty
            ? '${german.trim()}는 중요한 표현이에요.'
            : exampleTranslation.trim(),
        grammarNote: Value(_nullableText(grammarNote)),
        deck: deck.trim().isEmpty ? const Value('My Deck') : Value(deck.trim()),
        difficulty: const Value(1),
        mastery: const Value(0),
        isBookmarked: const Value(true),
        timesReviewed: const Value(0),
        nextReviewAt: Value(now),
        createdAt: Value(now),
        isDailyRecommendation: Value(isDailyRecommendation),
        dailyRecommendationDateKey: Value(
          recommendationDate == null
              ? null
              : dailyRecommendationDateKey(recommendationDate),
        ),
      ),
    );
  }

  Future<void> toggleBookmark(VocabWord word) {
    return update(
      vocabWords,
    ).replace(word.copyWith(isBookmarked: !word.isBookmarked));
  }

  Future<void> updateWordTtsLocale(VocabWord word, String ttsLocale) {
    return (update(
      vocabWords,
    )..where((table) => table.id.equals(word.id))).write(
      VocabWordsCompanion(
        ttsLocale: Value(
          voiceLocaleForLanguageCode(
            languageCode: word.languageCode,
            requestedLocale: ttsLocale,
          ),
        ),
      ),
    );
  }

  Future<void> updateAppPreferences({
    required String appLanguageCode,
    required String studyLanguageCode,
    required String aiProviderCode,
  }) async {
    await into(appPreferencesEntries).insertOnConflictUpdate(
      AppPreferencesEntriesCompanion.insert(
        id: const Value(1),
        appLanguageCode: Value(appLanguageCode),
        studyLanguageCode: Value(studyLanguageCode),
        aiProviderCode: Value(aiProviderCode),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> reviewWord(VocabWord word, {required bool remembered}) async {
    final now = DateTime.now();
    final mastery = remembered
        ? min(word.mastery + 1, 5)
        : max(word.mastery - 1, 0);
    final nextReviewAt = now.add(_nextReviewDelay(mastery, remembered));

    await transaction(() async {
      await (update(vocabWords)..where((tbl) => tbl.id.equals(word.id))).write(
        VocabWordsCompanion(
          mastery: Value(mastery),
          timesReviewed: Value(word.timesReviewed + 1),
          lastReviewedAt: Value(now.millisecondsSinceEpoch),
          nextReviewAt: Value(nextReviewAt.millisecondsSinceEpoch),
        ),
      );

      await into(studySessions).insert(
        StudySessionsCompanion.insert(
          studiedAt: now.millisecondsSinceEpoch,
          reviewedCount: const Value(1),
          masteredCount: Value(remembered && mastery >= 4 ? 1 : 0),
          minutesSpent: Value(remembered ? 3 : 4),
        ),
      );
    });
  }

  Future<ReadingDocument> upsertReadingDocument({
    required String sourceUrl,
    required String sourceTitle,
    String? sourceName,
    String? description,
    String? scriptText,
    DateTime? publishedAt,
  }) async {
    final existing = await (select(
      readingDocuments,
    )..where((table) => table.sourceUrl.equals(sourceUrl))).getSingleOrNull();
    final now = DateTime.now().millisecondsSinceEpoch;
    final preparedScript = scriptText?.trim();
    final initialScript = preparedScript == null || preparedScript.isEmpty
        ? _initialReadingScript(title: sourceTitle, description: description)
        : preparedScript;

    if (existing == null) {
      final id = await into(readingDocuments).insert(
        ReadingDocumentsCompanion.insert(
          sourceUrl: sourceUrl,
          sourceTitle: sourceTitle,
          sourceName: Value(
            sourceName?.trim().isEmpty ?? true ? null : sourceName,
          ),
          description: Value(
            description?.trim().isEmpty ?? true ? null : description,
          ),
          scriptText: initialScript,
          publishedAt: Value(publishedAt?.millisecondsSinceEpoch),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      return (select(
        readingDocuments,
      )..where((table) => table.id.equals(id))).getSingle();
    }

    final nextScript = existing.scriptText.trim().isEmpty
        ? initialScript
        : existing.scriptText;

    await (update(
      readingDocuments,
    )..where((table) => table.id.equals(existing.id))).write(
      ReadingDocumentsCompanion(
        sourceTitle: Value(sourceTitle),
        sourceName: Value(
          sourceName?.trim().isEmpty ?? true ? null : sourceName,
        ),
        description: Value(
          description?.trim().isEmpty ?? true ? null : description,
        ),
        scriptText: Value(nextScript),
        publishedAt: Value(publishedAt?.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );

    return (select(
      readingDocuments,
    )..where((table) => table.id.equals(existing.id))).getSingle();
  }

  Future<void> updateReadingScript(int documentId, String scriptText) {
    return (update(
      readingDocuments,
    )..where((table) => table.id.equals(documentId))).write(
      ReadingDocumentsCompanion(
        scriptText: Value(scriptText.trim()),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<ReadingDocument> getReadingDocumentById(int documentId) {
    return (select(
      readingDocuments,
    )..where((table) => table.id.equals(documentId))).getSingle();
  }

  Future<bool> toggleReadingNote({
    required int documentId,
    required String noteType,
    required String surfaceText,
    String? normalizedText,
    String? meaning,
    String? explanation,
    String? contextSnippet,
  }) async {
    final surface = surfaceText.trim();
    final normalized = normalizedText?.trim();

    final existing =
        await (select(readingNotes)..where(
              (table) =>
                  table.documentId.equals(documentId) &
                  table.noteType.equals(noteType) &
                  (normalized != null && normalized.isNotEmpty
                      ? table.normalizedText.equals(normalized)
                      : table.surfaceText.equals(surface)),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (delete(
        readingNotes,
      )..where((table) => table.id.equals(existing.id))).go();
      return false;
    }

    await into(readingNotes).insert(
      ReadingNotesCompanion.insert(
        documentId: documentId,
        noteType: noteType,
        surfaceText: surface,
        normalizedText: Value(
          normalized == null || normalized.isEmpty ? null : normalized,
        ),
        meaning: Value(_nullableText(meaning)),
        explanation: Value(_nullableText(explanation)),
        contextSnippet: Value(_nullableText(contextSnippet)),
      ),
    );
    return true;
  }

  Future<NewsCacheEntry?> getNewsCacheEntry(String cacheKey) {
    return (select(
      newsCacheEntries,
    )..where((table) => table.cacheKey.equals(cacheKey))).getSingleOrNull();
  }

  Future<void> saveNewsCacheEntry({
    required String cacheKey,
    required String payloadJson,
  }) async {
    final existing = await getNewsCacheEntry(cacheKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing == null) {
      await into(newsCacheEntries).insert(
        NewsCacheEntriesCompanion.insert(
          cacheKey: cacheKey,
          payloadJson: payloadJson,
          fetchedAt: Value(now),
        ),
      );
      return;
    }

    await (update(
      newsCacheEntries,
    )..where((table) => table.id.equals(existing.id))).write(
      NewsCacheEntriesCompanion(
        payloadJson: Value(payloadJson),
        fetchedAt: Value(now),
      ),
    );
  }

  Future<bool> upsertPracticeExamEntry({
    required String languageCode,
    required String sourceKey,
    required String payloadJson,
  }) async {
    final existing =
        await (select(practiceExamEntries)..where(
              (table) =>
                  table.languageCode.equals(languageCode) &
                  table.sourceKey.equals(sourceKey),
            ))
            .getSingleOrNull();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing == null) {
      await into(practiceExamEntries).insert(
        PracticeExamEntriesCompanion.insert(
          languageCode: Value(
            languageCode.trim().isEmpty ? 'de' : languageCode,
          ),
          sourceKey: sourceKey,
          payloadJson: payloadJson,
          createdAt: Value(now),
        ),
      );
      return true;
    }

    await (update(
      practiceExamEntries,
    )..where((table) => table.id.equals(existing.id))).write(
      PracticeExamEntriesCompanion(
        payloadJson: Value(payloadJson),
        updatedAt: Value(now),
      ),
    );
    return false;
  }

  Future<void> deletePracticeExamEntry(int id) {
    return (delete(
      practiceExamEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> _ensureImmersionTables() async {
    await customStatement('''
CREATE TABLE IF NOT EXISTS reading_documents (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  source_url TEXT NOT NULL UNIQUE,
  source_title TEXT NOT NULL,
  source_name TEXT NULL,
  description TEXT NULL,
  script_text TEXT NOT NULL,
  published_at INTEGER NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL
)
''');

    await customStatement('''
CREATE TABLE IF NOT EXISTS reading_notes (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  document_id INTEGER NOT NULL REFERENCES reading_documents(id),
  note_type TEXT NOT NULL,
  surface_text TEXT NOT NULL,
  normalized_text TEXT NULL,
  meaning TEXT NULL,
  explanation TEXT NULL,
  context_snippet TEXT NULL,
  created_at INTEGER NOT NULL
)
''');
  }

  Future<void> _ensureNewsCacheTable() async {
    await customStatement('''
CREATE TABLE IF NOT EXISTS news_cache_entries (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  cache_key TEXT NOT NULL UNIQUE,
  payload_json TEXT NOT NULL,
  fetched_at INTEGER NOT NULL
)
''');
  }

  Future<void> _ensureAppPreferencesTable() async {
    await customStatement('''
CREATE TABLE IF NOT EXISTS app_preferences_entries (
  id INTEGER NOT NULL PRIMARY KEY,
  app_language_code TEXT NOT NULL DEFAULT 'en',
  study_language_code TEXT NOT NULL DEFAULT 'de',
  ai_provider_code TEXT NOT NULL DEFAULT 'auto',
  updated_at INTEGER NOT NULL
)
''');
  }

  Future<void> _ensurePracticeExamEntriesTable() async {
    await customStatement('''
CREATE TABLE IF NOT EXISTS practice_exam_entries (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  language_code TEXT NOT NULL DEFAULT 'de',
  source_key TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL,
  UNIQUE(language_code, source_key)
)
''');
  }

  Future<void> _ensureAppPreferencesRow() async {
    final existing = await (select(
      appPreferencesEntries,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (existing != null) {
      return;
    }

    await into(appPreferencesEntries).insert(
      AppPreferencesEntriesCompanion.insert(
        id: const Value(1),
        appLanguageCode: const Value('en'),
        studyLanguageCode: const Value('de'),
        aiProviderCode: const Value('auto'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> ensureSeedData() async {
    final hasData = await (select(vocabWords)..limit(1)).getSingleOrNull();
    if (hasData != null) {
      return;
    }

    final now = DateTime.now();
    final words = _seedWords.map((seed) {
      final createdAt = now.subtract(Duration(days: seed.createdDaysAgo));
      final lastReviewed = now.subtract(
        Duration(hours: seed.lastReviewedHoursAgo),
      );
      final nextReviewAt = now.add(Duration(hours: seed.nextReviewInHours));

      return VocabWordsCompanion.insert(
        languageCode: const Value('de'),
        german: seed.german,
        article: _optionalText(seed.article),
        partOfSpeech: Value(seed.partOfSpeech),
        meaningEn: seed.meaningEn,
        meaningKo: seed.meaningKo,
        pronunciation: seed.pronunciation,
        ttsLocale: Value(seed.ttsLocale),
        exampleSentence: seed.exampleSentence,
        exampleTranslation: seed.exampleTranslation,
        grammarNote: Value(_nullableText(seed.grammarNote)),
        deck: Value(seed.deck),
        difficulty: Value(seed.difficulty),
        mastery: Value(seed.mastery),
        isBookmarked: Value(seed.bookmarked),
        timesReviewed: Value(seed.timesReviewed),
        nextReviewAt: Value(nextReviewAt.millisecondsSinceEpoch),
        lastReviewedAt: Value(lastReviewed.millisecondsSinceEpoch),
        isDailyRecommendation: Value(seed.isDailyRecommendation),
        dailyRecommendationDateKey: Value(
          seed.isDailyRecommendation
              ? dailyRecommendationDateKey(
                  now.subtract(Duration(days: seed.dailyRecommendationDaysAgo)),
                )
              : null,
        ),
        createdAt: Value(createdAt.millisecondsSinceEpoch),
      );
    }).toList();

    await batch((batch) {
      batch.insertAll(vocabWords, words);
      batch.insertAll(studySessions, _seedSessions(now));
    });
  }

  Duration _nextReviewDelay(int mastery, bool remembered) {
    if (!remembered) {
      return const Duration(hours: 6);
    }

    const ladder = <Duration>[
      Duration(hours: 8),
      Duration(days: 1),
      Duration(days: 2),
      Duration(days: 4),
      Duration(days: 7),
      Duration(days: 12),
    ];

    return ladder[mastery.clamp(0, ladder.length - 1)];
  }

  List<StudySessionsCompanion> _seedSessions(DateTime now) {
    return [
      _session(now.subtract(const Duration(hours: 2)), 8, 2, 18),
      _session(now.subtract(const Duration(days: 1, hours: 1)), 6, 1, 14),
      _session(now.subtract(const Duration(days: 2, hours: 3)), 7, 2, 16),
      _session(now.subtract(const Duration(days: 3, hours: 4)), 5, 1, 12),
      _session(now.subtract(const Duration(days: 4, hours: 2)), 9, 3, 20),
      _session(now.subtract(const Duration(days: 5, hours: 5)), 4, 1, 10),
      _session(now.subtract(const Duration(days: 6, hours: 2)), 6, 2, 15),
    ];
  }

  StudySessionsCompanion _session(
    DateTime date,
    int reviewed,
    int mastered,
    int minutes,
  ) {
    return StudySessionsCompanion.insert(
      studiedAt: date.millisecondsSinceEpoch,
      reviewedCount: Value(reviewed),
      masteredCount: Value(mastered),
      minutesSpent: Value(minutes),
    );
  }
}

Value<String?> _optionalText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return const Value.absent();
  }
  return Value(trimmed);
}

String dailyRecommendationDateKey(DateTime date) {
  final normalized = date.toLocal();
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _initialReadingScript({required String title, String? description}) {
  final parts = <String>[
    title.trim(),
    if (description != null && description.trim().isNotEmpty)
      description.trim(),
  ];

  return parts.join('\n\n');
}

final List<_SeedWord> _seedWords = [
  _SeedWord(
    german: 'Alltag',
    article: 'der',
    partOfSpeech: 'noun',
    meaningEn: 'daily life',
    meaningKo: '일상',
    pronunciation: '알탁',
    exampleSentence: 'Mein Alltag ist im Moment ziemlich ruhig.',
    exampleTranslation: '요즘 내 일상은 꽤 차분하다.',
    grammarNote: '명사는 der와 함께 외우면 남성 명사라는 점을 같이 기억하기 좋습니다.',
    deck: 'Starter',
    difficulty: 1,
    mastery: 3,
    bookmarked: true,
    timesReviewed: 8,
    isDailyRecommendation: true,
    dailyRecommendationDaysAgo: 0,
    createdDaysAgo: 14,
    lastReviewedHoursAgo: 20,
    nextReviewInHours: -2,
  ),
  _SeedWord(
    german: 'Wohnung',
    article: 'die',
    partOfSpeech: 'noun',
    meaningEn: 'apartment',
    meaningKo: '아파트, 집',
    pronunciation: '보눙',
    ttsLocale: 'de-AT',
    exampleSentence: 'Die Wohnung liegt direkt am Park.',
    exampleTranslation: '그 아파트는 공원 바로 옆에 있다.',
    grammarNote: 'Wohnung은 die가 붙는 여성 명사입니다. 관사와 함께 반복해 두면 성 구분이 쉬워집니다.',
    deck: 'Starter',
    difficulty: 1,
    mastery: 4,
    bookmarked: false,
    timesReviewed: 10,
    createdDaysAgo: 18,
    lastReviewedHoursAgo: 30,
    nextReviewInHours: 18,
  ),
  _SeedWord(
    german: 'lernen',
    partOfSpeech: 'verb',
    meaningEn: 'to study, to learn',
    meaningKo: '공부하다, 배우다',
    pronunciation: '레어넨',
    exampleSentence: 'Ich lerne jeden Morgen drei neue Woerter.',
    exampleTranslation: '나는 매일 아침 새 단어 세 개를 공부한다.',
    grammarNote: 'lernen은 동사 원형입니다. ich lerne처럼 인칭에 따라 어미가 바뀌는 점을 같이 보세요.',
    deck: 'Starter',
    difficulty: 1,
    mastery: 2,
    bookmarked: true,
    timesReviewed: 5,
    createdDaysAgo: 12,
    lastReviewedHoursAgo: 16,
    nextReviewInHours: -1,
  ),
  _SeedWord(
    german: 'bestellen',
    partOfSpeech: 'verb',
    meaningEn: 'to order',
    meaningKo: '주문하다',
    pronunciation: '베슈텔렌',
    exampleSentence: 'Wir bestellen heute nur eine Suppe und Brot.',
    exampleTranslation: '우리는 오늘 수프와 빵만 주문한다.',
    deck: 'Cafe',
    difficulty: 1,
    mastery: 1,
    bookmarked: false,
    timesReviewed: 3,
    createdDaysAgo: 9,
    lastReviewedHoursAgo: 8,
    nextReviewInHours: -3,
  ),
  _SeedWord(
    german: 'Rechnung',
    article: 'die',
    partOfSpeech: 'noun',
    meaningEn: 'bill, check',
    meaningKo: '계산서',
    pronunciation: '레흐눙',
    exampleSentence: 'Kann ich bitte die Rechnung bekommen?',
    exampleTranslation: '계산서 좀 받을 수 있을까요?',
    deck: 'Cafe',
    difficulty: 2,
    mastery: 2,
    bookmarked: true,
    timesReviewed: 4,
    createdDaysAgo: 11,
    lastReviewedHoursAgo: 18,
    nextReviewInHours: 12,
  ),
  _SeedWord(
    german: 'lecker',
    partOfSpeech: 'adjective',
    meaningEn: 'delicious, tasty',
    meaningKo: '맛있는',
    pronunciation: '레커',
    exampleSentence: 'Der Kuchen sieht wirklich lecker aus.',
    exampleTranslation: '그 케이크는 정말 맛있어 보인다.',
    deck: 'Cafe',
    difficulty: 1,
    mastery: 3,
    bookmarked: false,
    timesReviewed: 6,
    createdDaysAgo: 10,
    lastReviewedHoursAgo: 24,
    nextReviewInHours: 22,
  ),
  _SeedWord(
    german: 'Bahnhof',
    article: 'der',
    partOfSpeech: 'noun',
    meaningEn: 'train station',
    meaningKo: '기차역',
    pronunciation: '반호프',
    ttsLocale: 'de-CH',
    exampleSentence: 'Der Bahnhof ist nur zehn Minuten entfernt.',
    exampleTranslation: '기차역은 불과 10분 거리에 있다.',
    deck: 'Travel',
    difficulty: 2,
    mastery: 1,
    bookmarked: true,
    timesReviewed: 2,
    createdDaysAgo: 7,
    lastReviewedHoursAgo: 6,
    nextReviewInHours: -4,
  ),
  _SeedWord(
    german: 'umsteigen',
    partOfSpeech: 'verb',
    meaningEn: 'to transfer',
    meaningKo: '갈아타다',
    pronunciation: '움슈타이겐',
    exampleSentence: 'In Berlin musst du einmal umsteigen.',
    exampleTranslation: '베를린에서는 한 번 갈아타야 한다.',
    deck: 'Travel',
    difficulty: 3,
    mastery: 1,
    bookmarked: false,
    timesReviewed: 2,
    createdDaysAgo: 6,
    lastReviewedHoursAgo: 9,
    nextReviewInHours: -5,
  ),
  _SeedWord(
    german: 'Unterkunft',
    article: 'die',
    partOfSpeech: 'noun',
    meaningEn: 'accommodation',
    meaningKo: '숙소',
    pronunciation: '운터쿤프트',
    exampleSentence: 'Unsere Unterkunft liegt in der Altstadt.',
    exampleTranslation: '우리 숙소는 구시가지에 있다.',
    deck: 'Travel',
    difficulty: 2,
    mastery: 3,
    bookmarked: false,
    timesReviewed: 6,
    createdDaysAgo: 8,
    lastReviewedHoursAgo: 25,
    nextReviewInHours: 36,
  ),
  _SeedWord(
    german: 'Bewerbung',
    article: 'die',
    partOfSpeech: 'noun',
    meaningEn: 'application',
    meaningKo: '지원서',
    pronunciation: '베어붱',
    exampleSentence: 'Die Bewerbung muss bis Freitag fertig sein.',
    exampleTranslation: '지원서는 금요일까지 완성되어야 한다.',
    deck: 'Work',
    difficulty: 3,
    mastery: 2,
    bookmarked: true,
    timesReviewed: 4,
    createdDaysAgo: 13,
    lastReviewedHoursAgo: 21,
    nextReviewInHours: -6,
  ),
  _SeedWord(
    german: 'puenktlich',
    partOfSpeech: 'adjective',
    meaningEn: 'punctual',
    meaningKo: '시간을 잘 지키는',
    pronunciation: '퓡크틀리히',
    exampleSentence: 'Sie ist immer puenktlich im Buero.',
    exampleTranslation: '그녀는 사무실에 항상 제시간에 온다.',
    deck: 'Work',
    difficulty: 2,
    mastery: 4,
    bookmarked: false,
    timesReviewed: 9,
    createdDaysAgo: 15,
    lastReviewedHoursAgo: 40,
    nextReviewInHours: 60,
  ),
  _SeedWord(
    german: 'Gespraech',
    article: 'das',
    partOfSpeech: 'noun',
    meaningEn: 'conversation, interview',
    meaningKo: '대화, 면담',
    pronunciation: '게슈프레히',
    exampleSentence: 'Das Gespraech mit dem Team war sehr hilfreich.',
    exampleTranslation: '팀과의 대화는 아주 도움이 되었다.',
    deck: 'Work',
    difficulty: 2,
    mastery: 3,
    bookmarked: true,
    timesReviewed: 7,
    createdDaysAgo: 16,
    lastReviewedHoursAgo: 28,
    nextReviewInHours: 20,
  ),
];

class _SeedWord {
  const _SeedWord({
    required this.german,
    this.article,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningKo,
    required this.pronunciation,
    this.ttsLocale = defaultVoiceLocaleCode,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.grammarNote,
    required this.deck,
    required this.difficulty,
    required this.mastery,
    required this.bookmarked,
    required this.timesReviewed,
    this.isDailyRecommendation = false,
    this.dailyRecommendationDaysAgo = 0,
    required this.createdDaysAgo,
    required this.lastReviewedHoursAgo,
    required this.nextReviewInHours,
  });

  final String german;
  final String? article;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningKo;
  final String pronunciation;
  final String ttsLocale;
  final String exampleSentence;
  final String exampleTranslation;
  final String? grammarNote;
  final String deck;
  final int difficulty;
  final int mastery;
  final bool bookmarked;
  final int timesReviewed;
  final bool isDailyRecommendation;
  final int dailyRecommendationDaysAgo;
  final int createdDaysAgo;
  final int lastReviewedHoursAgo;
  final int nextReviewInHours;
}
