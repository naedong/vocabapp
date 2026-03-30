import 'dart:math';

import 'package:drift/drift.dart';

import 'db_connection.dart';

part 'app_database.g.dart';

class VocabWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get german => text()();
  TextColumn get article => text().nullable()();
  TextColumn get partOfSpeech =>
      text().withDefault(const Constant('expression'))();
  TextColumn get meaningEn => text()();
  TextColumn get meaningKo => text()();
  TextColumn get pronunciation => text()();
  TextColumn get exampleSentence => text()();
  TextColumn get exampleTranslation => text()();
  TextColumn get deck => text().withDefault(const Constant('Starter'))();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  IntColumn get mastery => integer().withDefault(const Constant(0))();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  IntColumn get timesReviewed => integer().withDefault(const Constant(0))();
  IntColumn get nextReviewAt => integer().nullable()();
  IntColumn get lastReviewedAt => integer().nullable()();
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

@DriftDatabase(tables: [VocabWords, StudySessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> initialize() async {
    await customStatement('PRAGMA foreign_keys = ON');
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

  Future<void> addWord({
    required String german,
    required String meaningEn,
    required String meaningKo,
    required String pronunciation,
    String? article,
    required String partOfSpeech,
    required String exampleSentence,
    required String exampleTranslation,
    required String deck,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await into(vocabWords).insert(
      VocabWordsCompanion.insert(
        german: german.trim(),
        article: _optionalText(article),
        partOfSpeech: partOfSpeech.trim().isEmpty
            ? const Value('expression')
            : Value(partOfSpeech.trim()),
        meaningEn: meaningEn.trim(),
        meaningKo: meaningKo.trim(),
        pronunciation: pronunciation.trim(),
        exampleSentence: exampleSentence.trim().isEmpty
            ? '${german.trim()} ist ein wichtiges Wort.'
            : exampleSentence.trim(),
        exampleTranslation: exampleTranslation.trim().isEmpty
            ? '${german.trim()}는 중요한 표현이에요.'
            : exampleTranslation.trim(),
        deck: deck.trim().isEmpty ? const Value('My Deck') : Value(deck.trim()),
        difficulty: const Value(1),
        mastery: const Value(0),
        isBookmarked: const Value(true),
        timesReviewed: const Value(0),
        nextReviewAt: Value(now),
        createdAt: Value(now),
      ),
    );
  }

  Future<void> toggleBookmark(VocabWord word) {
    return update(
      vocabWords,
    ).replace(word.copyWith(isBookmarked: !word.isBookmarked));
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
        german: seed.german,
        article: _optionalText(seed.article),
        partOfSpeech: Value(seed.partOfSpeech),
        meaningEn: seed.meaningEn,
        meaningKo: seed.meaningKo,
        pronunciation: seed.pronunciation,
        exampleSentence: seed.exampleSentence,
        exampleTranslation: seed.exampleTranslation,
        deck: Value(seed.deck),
        difficulty: Value(seed.difficulty),
        mastery: Value(seed.mastery),
        isBookmarked: Value(seed.bookmarked),
        timesReviewed: Value(seed.timesReviewed),
        nextReviewAt: Value(nextReviewAt.millisecondsSinceEpoch),
        lastReviewedAt: Value(lastReviewed.millisecondsSinceEpoch),
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
    deck: 'Starter',
    difficulty: 1,
    mastery: 3,
    bookmarked: true,
    timesReviewed: 8,
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
    exampleSentence: 'Die Wohnung liegt direkt am Park.',
    exampleTranslation: '그 아파트는 공원 바로 옆에 있다.',
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
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.deck,
    required this.difficulty,
    required this.mastery,
    required this.bookmarked,
    required this.timesReviewed,
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
  final String exampleSentence;
  final String exampleTranslation;
  final String deck;
  final int difficulty;
  final int mastery;
  final bool bookmarked;
  final int timesReviewed;
  final int createdDaysAgo;
  final int lastReviewedHoursAgo;
  final int nextReviewInHours;
}
