// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VocabWordsTable extends VocabWords
    with TableInfo<$VocabWordsTable, VocabWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _germanMeta = const VerificationMeta('german');
  @override
  late final GeneratedColumn<String> german = GeneratedColumn<String>(
    'german',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleMeta = const VerificationMeta(
    'article',
  );
  @override
  late final GeneratedColumn<String> article = GeneratedColumn<String>(
    'article',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expression'),
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  @override
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningKoMeta = const VerificationMeta(
    'meaningKo',
  );
  @override
  late final GeneratedColumn<String> meaningKo = GeneratedColumn<String>(
    'meaning_ko',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  @override
  late final GeneratedColumn<String> pronunciation = GeneratedColumn<String>(
    'pronunciation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttsLocaleMeta = const VerificationMeta(
    'ttsLocale',
  );
  @override
  late final GeneratedColumn<String> ttsLocale = GeneratedColumn<String>(
    'tts_locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultVoiceLocaleCode),
  );
  static const VerificationMeta _exampleSentenceMeta = const VerificationMeta(
    'exampleSentence',
  );
  @override
  late final GeneratedColumn<String> exampleSentence = GeneratedColumn<String>(
    'example_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleTranslationMeta =
      const VerificationMeta('exampleTranslation');
  @override
  late final GeneratedColumn<String> exampleTranslation =
      GeneratedColumn<String>(
        'example_translation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _grammarNoteMeta = const VerificationMeta(
    'grammarNote',
  );
  @override
  late final GeneratedColumn<String> grammarNote = GeneratedColumn<String>(
    'grammar_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deckMeta = const VerificationMeta('deck');
  @override
  late final GeneratedColumn<String> deck = GeneratedColumn<String>(
    'deck',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Starter'),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _masteryMeta = const VerificationMeta(
    'mastery',
  );
  @override
  late final GeneratedColumn<int> mastery = GeneratedColumn<int>(
    'mastery',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta(
    'isBookmarked',
  );
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timesReviewedMeta = const VerificationMeta(
    'timesReviewed',
  );
  @override
  late final GeneratedColumn<int> timesReviewed = GeneratedColumn<int>(
    'times_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<int> nextReviewAt = GeneratedColumn<int>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<int> lastReviewedAt = GeneratedColumn<int>(
    'last_reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDailyRecommendationMeta =
      const VerificationMeta('isDailyRecommendation');
  @override
  late final GeneratedColumn<bool> isDailyRecommendation =
      GeneratedColumn<bool>(
        'is_daily_recommendation',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_daily_recommendation" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _dailyRecommendationDateKeyMeta =
      const VerificationMeta('dailyRecommendationDateKey');
  @override
  late final GeneratedColumn<String> dailyRecommendationDateKey =
      GeneratedColumn<String>(
        'daily_recommendation_date_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    german,
    article,
    partOfSpeech,
    meaningEn,
    meaningKo,
    pronunciation,
    ttsLocale,
    exampleSentence,
    exampleTranslation,
    grammarNote,
    deck,
    difficulty,
    mastery,
    isBookmarked,
    timesReviewed,
    nextReviewAt,
    lastReviewedAt,
    isDailyRecommendation,
    dailyRecommendationDateKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocab_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('german')) {
      context.handle(
        _germanMeta,
        german.isAcceptableOrUnknown(data['german']!, _germanMeta),
      );
    } else if (isInserting) {
      context.missing(_germanMeta);
    }
    if (data.containsKey('article')) {
      context.handle(
        _articleMeta,
        article.isAcceptableOrUnknown(data['article']!, _articleMeta),
      );
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningEnMeta);
    }
    if (data.containsKey('meaning_ko')) {
      context.handle(
        _meaningKoMeta,
        meaningKo.isAcceptableOrUnknown(data['meaning_ko']!, _meaningKoMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningKoMeta);
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pronunciationMeta);
    }
    if (data.containsKey('tts_locale')) {
      context.handle(
        _ttsLocaleMeta,
        ttsLocale.isAcceptableOrUnknown(data['tts_locale']!, _ttsLocaleMeta),
      );
    }
    if (data.containsKey('example_sentence')) {
      context.handle(
        _exampleSentenceMeta,
        exampleSentence.isAcceptableOrUnknown(
          data['example_sentence']!,
          _exampleSentenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleSentenceMeta);
    }
    if (data.containsKey('example_translation')) {
      context.handle(
        _exampleTranslationMeta,
        exampleTranslation.isAcceptableOrUnknown(
          data['example_translation']!,
          _exampleTranslationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleTranslationMeta);
    }
    if (data.containsKey('grammar_note')) {
      context.handle(
        _grammarNoteMeta,
        grammarNote.isAcceptableOrUnknown(
          data['grammar_note']!,
          _grammarNoteMeta,
        ),
      );
    }
    if (data.containsKey('deck')) {
      context.handle(
        _deckMeta,
        deck.isAcceptableOrUnknown(data['deck']!, _deckMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('mastery')) {
      context.handle(
        _masteryMeta,
        mastery.isAcceptableOrUnknown(data['mastery']!, _masteryMeta),
      );
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(
          data['is_bookmarked']!,
          _isBookmarkedMeta,
        ),
      );
    }
    if (data.containsKey('times_reviewed')) {
      context.handle(
        _timesReviewedMeta,
        timesReviewed.isAcceptableOrUnknown(
          data['times_reviewed']!,
          _timesReviewedMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_daily_recommendation')) {
      context.handle(
        _isDailyRecommendationMeta,
        isDailyRecommendation.isAcceptableOrUnknown(
          data['is_daily_recommendation']!,
          _isDailyRecommendationMeta,
        ),
      );
    }
    if (data.containsKey('daily_recommendation_date_key')) {
      context.handle(
        _dailyRecommendationDateKeyMeta,
        dailyRecommendationDateKey.isAcceptableOrUnknown(
          data['daily_recommendation_date_key']!,
          _dailyRecommendationDateKeyMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      german: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}german'],
      )!,
      article: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article'],
      ),
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      )!,
      meaningKo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_ko'],
      )!,
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronunciation'],
      )!,
      ttsLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tts_locale'],
      )!,
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      )!,
      exampleTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_translation'],
      )!,
      grammarNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_note'],
      ),
      deck: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      mastery: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastery'],
      )!,
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      timesReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_reviewed'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_review_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      isDailyRecommendation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily_recommendation'],
      )!,
      dailyRecommendationDateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_recommendation_date_key'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VocabWordsTable createAlias(String alias) {
    return $VocabWordsTable(attachedDatabase, alias);
  }
}

class VocabWord extends DataClass implements Insertable<VocabWord> {
  final int id;
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
  final bool isBookmarked;
  final int timesReviewed;
  final int? nextReviewAt;
  final int? lastReviewedAt;
  final bool isDailyRecommendation;
  final String? dailyRecommendationDateKey;
  final int createdAt;
  const VocabWord({
    required this.id,
    required this.german,
    this.article,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningKo,
    required this.pronunciation,
    required this.ttsLocale,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.grammarNote,
    required this.deck,
    required this.difficulty,
    required this.mastery,
    required this.isBookmarked,
    required this.timesReviewed,
    this.nextReviewAt,
    this.lastReviewedAt,
    required this.isDailyRecommendation,
    this.dailyRecommendationDateKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['german'] = Variable<String>(german);
    if (!nullToAbsent || article != null) {
      map['article'] = Variable<String>(article);
    }
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['meaning_en'] = Variable<String>(meaningEn);
    map['meaning_ko'] = Variable<String>(meaningKo);
    map['pronunciation'] = Variable<String>(pronunciation);
    map['tts_locale'] = Variable<String>(ttsLocale);
    map['example_sentence'] = Variable<String>(exampleSentence);
    map['example_translation'] = Variable<String>(exampleTranslation);
    if (!nullToAbsent || grammarNote != null) {
      map['grammar_note'] = Variable<String>(grammarNote);
    }
    map['deck'] = Variable<String>(deck);
    map['difficulty'] = Variable<int>(difficulty);
    map['mastery'] = Variable<int>(mastery);
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    map['times_reviewed'] = Variable<int>(timesReviewed);
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<int>(nextReviewAt);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<int>(lastReviewedAt);
    }
    map['is_daily_recommendation'] = Variable<bool>(isDailyRecommendation);
    if (!nullToAbsent || dailyRecommendationDateKey != null) {
      map['daily_recommendation_date_key'] = Variable<String>(
        dailyRecommendationDateKey,
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  VocabWordsCompanion toCompanion(bool nullToAbsent) {
    return VocabWordsCompanion(
      id: Value(id),
      german: Value(german),
      article: article == null && nullToAbsent
          ? const Value.absent()
          : Value(article),
      partOfSpeech: Value(partOfSpeech),
      meaningEn: Value(meaningEn),
      meaningKo: Value(meaningKo),
      pronunciation: Value(pronunciation),
      ttsLocale: Value(ttsLocale),
      exampleSentence: Value(exampleSentence),
      exampleTranslation: Value(exampleTranslation),
      grammarNote: grammarNote == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarNote),
      deck: Value(deck),
      difficulty: Value(difficulty),
      mastery: Value(mastery),
      isBookmarked: Value(isBookmarked),
      timesReviewed: Value(timesReviewed),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      isDailyRecommendation: Value(isDailyRecommendation),
      dailyRecommendationDateKey:
          dailyRecommendationDateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyRecommendationDateKey),
      createdAt: Value(createdAt),
    );
  }

  factory VocabWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabWord(
      id: serializer.fromJson<int>(json['id']),
      german: serializer.fromJson<String>(json['german']),
      article: serializer.fromJson<String?>(json['article']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      meaningEn: serializer.fromJson<String>(json['meaningEn']),
      meaningKo: serializer.fromJson<String>(json['meaningKo']),
      pronunciation: serializer.fromJson<String>(json['pronunciation']),
      ttsLocale: serializer.fromJson<String>(json['ttsLocale']),
      exampleSentence: serializer.fromJson<String>(json['exampleSentence']),
      exampleTranslation: serializer.fromJson<String>(
        json['exampleTranslation'],
      ),
      grammarNote: serializer.fromJson<String?>(json['grammarNote']),
      deck: serializer.fromJson<String>(json['deck']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      mastery: serializer.fromJson<int>(json['mastery']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      timesReviewed: serializer.fromJson<int>(json['timesReviewed']),
      nextReviewAt: serializer.fromJson<int?>(json['nextReviewAt']),
      lastReviewedAt: serializer.fromJson<int?>(json['lastReviewedAt']),
      isDailyRecommendation: serializer.fromJson<bool>(
        json['isDailyRecommendation'],
      ),
      dailyRecommendationDateKey: serializer.fromJson<String?>(
        json['dailyRecommendationDateKey'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'german': serializer.toJson<String>(german),
      'article': serializer.toJson<String?>(article),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'meaningEn': serializer.toJson<String>(meaningEn),
      'meaningKo': serializer.toJson<String>(meaningKo),
      'pronunciation': serializer.toJson<String>(pronunciation),
      'ttsLocale': serializer.toJson<String>(ttsLocale),
      'exampleSentence': serializer.toJson<String>(exampleSentence),
      'exampleTranslation': serializer.toJson<String>(exampleTranslation),
      'grammarNote': serializer.toJson<String?>(grammarNote),
      'deck': serializer.toJson<String>(deck),
      'difficulty': serializer.toJson<int>(difficulty),
      'mastery': serializer.toJson<int>(mastery),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'timesReviewed': serializer.toJson<int>(timesReviewed),
      'nextReviewAt': serializer.toJson<int?>(nextReviewAt),
      'lastReviewedAt': serializer.toJson<int?>(lastReviewedAt),
      'isDailyRecommendation': serializer.toJson<bool>(isDailyRecommendation),
      'dailyRecommendationDateKey': serializer.toJson<String?>(
        dailyRecommendationDateKey,
      ),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  VocabWord copyWith({
    int? id,
    String? german,
    Value<String?> article = const Value.absent(),
    String? partOfSpeech,
    String? meaningEn,
    String? meaningKo,
    String? pronunciation,
    String? ttsLocale,
    String? exampleSentence,
    String? exampleTranslation,
    Value<String?> grammarNote = const Value.absent(),
    String? deck,
    int? difficulty,
    int? mastery,
    bool? isBookmarked,
    int? timesReviewed,
    Value<int?> nextReviewAt = const Value.absent(),
    Value<int?> lastReviewedAt = const Value.absent(),
    bool? isDailyRecommendation,
    Value<String?> dailyRecommendationDateKey = const Value.absent(),
    int? createdAt,
  }) => VocabWord(
    id: id ?? this.id,
    german: german ?? this.german,
    article: article.present ? article.value : this.article,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    meaningEn: meaningEn ?? this.meaningEn,
    meaningKo: meaningKo ?? this.meaningKo,
    pronunciation: pronunciation ?? this.pronunciation,
    ttsLocale: ttsLocale ?? this.ttsLocale,
    exampleSentence: exampleSentence ?? this.exampleSentence,
    exampleTranslation: exampleTranslation ?? this.exampleTranslation,
    grammarNote: grammarNote.present ? grammarNote.value : this.grammarNote,
    deck: deck ?? this.deck,
    difficulty: difficulty ?? this.difficulty,
    mastery: mastery ?? this.mastery,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    timesReviewed: timesReviewed ?? this.timesReviewed,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    isDailyRecommendation: isDailyRecommendation ?? this.isDailyRecommendation,
    dailyRecommendationDateKey: dailyRecommendationDateKey.present
        ? dailyRecommendationDateKey.value
        : this.dailyRecommendationDateKey,
    createdAt: createdAt ?? this.createdAt,
  );
  VocabWord copyWithCompanion(VocabWordsCompanion data) {
    return VocabWord(
      id: data.id.present ? data.id.value : this.id,
      german: data.german.present ? data.german.value : this.german,
      article: data.article.present ? data.article.value : this.article,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      meaningKo: data.meaningKo.present ? data.meaningKo.value : this.meaningKo,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      ttsLocale: data.ttsLocale.present ? data.ttsLocale.value : this.ttsLocale,
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      exampleTranslation: data.exampleTranslation.present
          ? data.exampleTranslation.value
          : this.exampleTranslation,
      grammarNote: data.grammarNote.present
          ? data.grammarNote.value
          : this.grammarNote,
      deck: data.deck.present ? data.deck.value : this.deck,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      mastery: data.mastery.present ? data.mastery.value : this.mastery,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      timesReviewed: data.timesReviewed.present
          ? data.timesReviewed.value
          : this.timesReviewed,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      isDailyRecommendation: data.isDailyRecommendation.present
          ? data.isDailyRecommendation.value
          : this.isDailyRecommendation,
      dailyRecommendationDateKey: data.dailyRecommendationDateKey.present
          ? data.dailyRecommendationDateKey.value
          : this.dailyRecommendationDateKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabWord(')
          ..write('id: $id, ')
          ..write('german: $german, ')
          ..write('article: $article, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('meaningKo: $meaningKo, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('ttsLocale: $ttsLocale, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('grammarNote: $grammarNote, ')
          ..write('deck: $deck, ')
          ..write('difficulty: $difficulty, ')
          ..write('mastery: $mastery, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('isDailyRecommendation: $isDailyRecommendation, ')
          ..write('dailyRecommendationDateKey: $dailyRecommendationDateKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    german,
    article,
    partOfSpeech,
    meaningEn,
    meaningKo,
    pronunciation,
    ttsLocale,
    exampleSentence,
    exampleTranslation,
    grammarNote,
    deck,
    difficulty,
    mastery,
    isBookmarked,
    timesReviewed,
    nextReviewAt,
    lastReviewedAt,
    isDailyRecommendation,
    dailyRecommendationDateKey,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabWord &&
          other.id == this.id &&
          other.german == this.german &&
          other.article == this.article &&
          other.partOfSpeech == this.partOfSpeech &&
          other.meaningEn == this.meaningEn &&
          other.meaningKo == this.meaningKo &&
          other.pronunciation == this.pronunciation &&
          other.ttsLocale == this.ttsLocale &&
          other.exampleSentence == this.exampleSentence &&
          other.exampleTranslation == this.exampleTranslation &&
          other.grammarNote == this.grammarNote &&
          other.deck == this.deck &&
          other.difficulty == this.difficulty &&
          other.mastery == this.mastery &&
          other.isBookmarked == this.isBookmarked &&
          other.timesReviewed == this.timesReviewed &&
          other.nextReviewAt == this.nextReviewAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.isDailyRecommendation == this.isDailyRecommendation &&
          other.dailyRecommendationDateKey == this.dailyRecommendationDateKey &&
          other.createdAt == this.createdAt);
}

class VocabWordsCompanion extends UpdateCompanion<VocabWord> {
  final Value<int> id;
  final Value<String> german;
  final Value<String?> article;
  final Value<String> partOfSpeech;
  final Value<String> meaningEn;
  final Value<String> meaningKo;
  final Value<String> pronunciation;
  final Value<String> ttsLocale;
  final Value<String> exampleSentence;
  final Value<String> exampleTranslation;
  final Value<String?> grammarNote;
  final Value<String> deck;
  final Value<int> difficulty;
  final Value<int> mastery;
  final Value<bool> isBookmarked;
  final Value<int> timesReviewed;
  final Value<int?> nextReviewAt;
  final Value<int?> lastReviewedAt;
  final Value<bool> isDailyRecommendation;
  final Value<String?> dailyRecommendationDateKey;
  final Value<int> createdAt;
  const VocabWordsCompanion({
    this.id = const Value.absent(),
    this.german = const Value.absent(),
    this.article = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.meaningKo = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.ttsLocale = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.grammarNote = const Value.absent(),
    this.deck = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mastery = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.isDailyRecommendation = const Value.absent(),
    this.dailyRecommendationDateKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VocabWordsCompanion.insert({
    this.id = const Value.absent(),
    required String german,
    this.article = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    required String meaningEn,
    required String meaningKo,
    required String pronunciation,
    this.ttsLocale = const Value.absent(),
    required String exampleSentence,
    required String exampleTranslation,
    this.grammarNote = const Value.absent(),
    this.deck = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mastery = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.isDailyRecommendation = const Value.absent(),
    this.dailyRecommendationDateKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : german = Value(german),
       meaningEn = Value(meaningEn),
       meaningKo = Value(meaningKo),
       pronunciation = Value(pronunciation),
       exampleSentence = Value(exampleSentence),
       exampleTranslation = Value(exampleTranslation);
  static Insertable<VocabWord> custom({
    Expression<int>? id,
    Expression<String>? german,
    Expression<String>? article,
    Expression<String>? partOfSpeech,
    Expression<String>? meaningEn,
    Expression<String>? meaningKo,
    Expression<String>? pronunciation,
    Expression<String>? ttsLocale,
    Expression<String>? exampleSentence,
    Expression<String>? exampleTranslation,
    Expression<String>? grammarNote,
    Expression<String>? deck,
    Expression<int>? difficulty,
    Expression<int>? mastery,
    Expression<bool>? isBookmarked,
    Expression<int>? timesReviewed,
    Expression<int>? nextReviewAt,
    Expression<int>? lastReviewedAt,
    Expression<bool>? isDailyRecommendation,
    Expression<String>? dailyRecommendationDateKey,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (german != null) 'german': german,
      if (article != null) 'article': article,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (meaningKo != null) 'meaning_ko': meaningKo,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (ttsLocale != null) 'tts_locale': ttsLocale,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (exampleTranslation != null) 'example_translation': exampleTranslation,
      if (grammarNote != null) 'grammar_note': grammarNote,
      if (deck != null) 'deck': deck,
      if (difficulty != null) 'difficulty': difficulty,
      if (mastery != null) 'mastery': mastery,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (timesReviewed != null) 'times_reviewed': timesReviewed,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (isDailyRecommendation != null)
        'is_daily_recommendation': isDailyRecommendation,
      if (dailyRecommendationDateKey != null)
        'daily_recommendation_date_key': dailyRecommendationDateKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VocabWordsCompanion copyWith({
    Value<int>? id,
    Value<String>? german,
    Value<String?>? article,
    Value<String>? partOfSpeech,
    Value<String>? meaningEn,
    Value<String>? meaningKo,
    Value<String>? pronunciation,
    Value<String>? ttsLocale,
    Value<String>? exampleSentence,
    Value<String>? exampleTranslation,
    Value<String?>? grammarNote,
    Value<String>? deck,
    Value<int>? difficulty,
    Value<int>? mastery,
    Value<bool>? isBookmarked,
    Value<int>? timesReviewed,
    Value<int?>? nextReviewAt,
    Value<int?>? lastReviewedAt,
    Value<bool>? isDailyRecommendation,
    Value<String?>? dailyRecommendationDateKey,
    Value<int>? createdAt,
  }) {
    return VocabWordsCompanion(
      id: id ?? this.id,
      german: german ?? this.german,
      article: article ?? this.article,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningKo: meaningKo ?? this.meaningKo,
      pronunciation: pronunciation ?? this.pronunciation,
      ttsLocale: ttsLocale ?? this.ttsLocale,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      grammarNote: grammarNote ?? this.grammarNote,
      deck: deck ?? this.deck,
      difficulty: difficulty ?? this.difficulty,
      mastery: mastery ?? this.mastery,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isDailyRecommendation:
          isDailyRecommendation ?? this.isDailyRecommendation,
      dailyRecommendationDateKey:
          dailyRecommendationDateKey ?? this.dailyRecommendationDateKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (german.present) {
      map['german'] = Variable<String>(german.value);
    }
    if (article.present) {
      map['article'] = Variable<String>(article.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (meaningKo.present) {
      map['meaning_ko'] = Variable<String>(meaningKo.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<String>(pronunciation.value);
    }
    if (ttsLocale.present) {
      map['tts_locale'] = Variable<String>(ttsLocale.value);
    }
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (exampleTranslation.present) {
      map['example_translation'] = Variable<String>(exampleTranslation.value);
    }
    if (grammarNote.present) {
      map['grammar_note'] = Variable<String>(grammarNote.value);
    }
    if (deck.present) {
      map['deck'] = Variable<String>(deck.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (mastery.present) {
      map['mastery'] = Variable<int>(mastery.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (timesReviewed.present) {
      map['times_reviewed'] = Variable<int>(timesReviewed.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<int>(nextReviewAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<int>(lastReviewedAt.value);
    }
    if (isDailyRecommendation.present) {
      map['is_daily_recommendation'] = Variable<bool>(
        isDailyRecommendation.value,
      );
    }
    if (dailyRecommendationDateKey.present) {
      map['daily_recommendation_date_key'] = Variable<String>(
        dailyRecommendationDateKey.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabWordsCompanion(')
          ..write('id: $id, ')
          ..write('german: $german, ')
          ..write('article: $article, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('meaningKo: $meaningKo, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('ttsLocale: $ttsLocale, ')
          ..write('exampleSentence: $exampleSentence, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('grammarNote: $grammarNote, ')
          ..write('deck: $deck, ')
          ..write('difficulty: $difficulty, ')
          ..write('mastery: $mastery, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('isDailyRecommendation: $isDailyRecommendation, ')
          ..write('dailyRecommendationDateKey: $dailyRecommendationDateKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _studiedAtMeta = const VerificationMeta(
    'studiedAt',
  );
  @override
  late final GeneratedColumn<int> studiedAt = GeneratedColumn<int>(
    'studied_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedCountMeta = const VerificationMeta(
    'reviewedCount',
  );
  @override
  late final GeneratedColumn<int> reviewedCount = GeneratedColumn<int>(
    'reviewed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _masteredCountMeta = const VerificationMeta(
    'masteredCount',
  );
  @override
  late final GeneratedColumn<int> masteredCount = GeneratedColumn<int>(
    'mastered_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minutesSpentMeta = const VerificationMeta(
    'minutesSpent',
  );
  @override
  late final GeneratedColumn<int> minutesSpent = GeneratedColumn<int>(
    'minutes_spent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studiedAt,
    reviewedCount,
    masteredCount,
    minutesSpent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('studied_at')) {
      context.handle(
        _studiedAtMeta,
        studiedAt.isAcceptableOrUnknown(data['studied_at']!, _studiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_studiedAtMeta);
    }
    if (data.containsKey('reviewed_count')) {
      context.handle(
        _reviewedCountMeta,
        reviewedCount.isAcceptableOrUnknown(
          data['reviewed_count']!,
          _reviewedCountMeta,
        ),
      );
    }
    if (data.containsKey('mastered_count')) {
      context.handle(
        _masteredCountMeta,
        masteredCount.isAcceptableOrUnknown(
          data['mastered_count']!,
          _masteredCountMeta,
        ),
      );
    }
    if (data.containsKey('minutes_spent')) {
      context.handle(
        _minutesSpentMeta,
        minutesSpent.isAcceptableOrUnknown(
          data['minutes_spent']!,
          _minutesSpentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}studied_at'],
      )!,
      reviewedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_count'],
      )!,
      masteredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastered_count'],
      )!,
      minutesSpent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_spent'],
      )!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final int id;
  final int studiedAt;
  final int reviewedCount;
  final int masteredCount;
  final int minutesSpent;
  const StudySession({
    required this.id,
    required this.studiedAt,
    required this.reviewedCount,
    required this.masteredCount,
    required this.minutesSpent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['studied_at'] = Variable<int>(studiedAt);
    map['reviewed_count'] = Variable<int>(reviewedCount);
    map['mastered_count'] = Variable<int>(masteredCount);
    map['minutes_spent'] = Variable<int>(minutesSpent);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      studiedAt: Value(studiedAt),
      reviewedCount: Value(reviewedCount),
      masteredCount: Value(masteredCount),
      minutesSpent: Value(minutesSpent),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<int>(json['id']),
      studiedAt: serializer.fromJson<int>(json['studiedAt']),
      reviewedCount: serializer.fromJson<int>(json['reviewedCount']),
      masteredCount: serializer.fromJson<int>(json['masteredCount']),
      minutesSpent: serializer.fromJson<int>(json['minutesSpent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studiedAt': serializer.toJson<int>(studiedAt),
      'reviewedCount': serializer.toJson<int>(reviewedCount),
      'masteredCount': serializer.toJson<int>(masteredCount),
      'minutesSpent': serializer.toJson<int>(minutesSpent),
    };
  }

  StudySession copyWith({
    int? id,
    int? studiedAt,
    int? reviewedCount,
    int? masteredCount,
    int? minutesSpent,
  }) => StudySession(
    id: id ?? this.id,
    studiedAt: studiedAt ?? this.studiedAt,
    reviewedCount: reviewedCount ?? this.reviewedCount,
    masteredCount: masteredCount ?? this.masteredCount,
    minutesSpent: minutesSpent ?? this.minutesSpent,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      studiedAt: data.studiedAt.present ? data.studiedAt.value : this.studiedAt,
      reviewedCount: data.reviewedCount.present
          ? data.reviewedCount.value
          : this.reviewedCount,
      masteredCount: data.masteredCount.present
          ? data.masteredCount.value
          : this.masteredCount,
      minutesSpent: data.minutesSpent.present
          ? data.minutesSpent.value
          : this.minutesSpent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('studiedAt: $studiedAt, ')
          ..write('reviewedCount: $reviewedCount, ')
          ..write('masteredCount: $masteredCount, ')
          ..write('minutesSpent: $minutesSpent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studiedAt, reviewedCount, masteredCount, minutesSpent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.studiedAt == this.studiedAt &&
          other.reviewedCount == this.reviewedCount &&
          other.masteredCount == this.masteredCount &&
          other.minutesSpent == this.minutesSpent);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<int> id;
  final Value<int> studiedAt;
  final Value<int> reviewedCount;
  final Value<int> masteredCount;
  final Value<int> minutesSpent;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.studiedAt = const Value.absent(),
    this.reviewedCount = const Value.absent(),
    this.masteredCount = const Value.absent(),
    this.minutesSpent = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    this.id = const Value.absent(),
    required int studiedAt,
    this.reviewedCount = const Value.absent(),
    this.masteredCount = const Value.absent(),
    this.minutesSpent = const Value.absent(),
  }) : studiedAt = Value(studiedAt);
  static Insertable<StudySession> custom({
    Expression<int>? id,
    Expression<int>? studiedAt,
    Expression<int>? reviewedCount,
    Expression<int>? masteredCount,
    Expression<int>? minutesSpent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studiedAt != null) 'studied_at': studiedAt,
      if (reviewedCount != null) 'reviewed_count': reviewedCount,
      if (masteredCount != null) 'mastered_count': masteredCount,
      if (minutesSpent != null) 'minutes_spent': minutesSpent,
    });
  }

  StudySessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? studiedAt,
    Value<int>? reviewedCount,
    Value<int>? masteredCount,
    Value<int>? minutesSpent,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      studiedAt: studiedAt ?? this.studiedAt,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      masteredCount: masteredCount ?? this.masteredCount,
      minutesSpent: minutesSpent ?? this.minutesSpent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studiedAt.present) {
      map['studied_at'] = Variable<int>(studiedAt.value);
    }
    if (reviewedCount.present) {
      map['reviewed_count'] = Variable<int>(reviewedCount.value);
    }
    if (masteredCount.present) {
      map['mastered_count'] = Variable<int>(masteredCount.value);
    }
    if (minutesSpent.present) {
      map['minutes_spent'] = Variable<int>(minutesSpent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('studiedAt: $studiedAt, ')
          ..write('reviewedCount: $reviewedCount, ')
          ..write('masteredCount: $masteredCount, ')
          ..write('minutesSpent: $minutesSpent')
          ..write(')'))
        .toString();
  }
}

class $ReadingDocumentsTable extends ReadingDocuments
    with TableInfo<$ReadingDocumentsTable, ReadingDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTitleMeta = const VerificationMeta(
    'sourceTitle',
  );
  @override
  late final GeneratedColumn<String> sourceTitle = GeneratedColumn<String>(
    'source_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scriptTextMeta = const VerificationMeta(
    'scriptText',
  );
  @override
  late final GeneratedColumn<String> scriptText = GeneratedColumn<String>(
    'script_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<int> publishedAt = GeneratedColumn<int>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceUrl,
    sourceTitle,
    sourceName,
    description,
    scriptText,
    publishedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('source_title')) {
      context.handle(
        _sourceTitleMeta,
        sourceTitle.isAcceptableOrUnknown(
          data['source_title']!,
          _sourceTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTitleMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('script_text')) {
      context.handle(
        _scriptTextMeta,
        scriptText.isAcceptableOrUnknown(data['script_text']!, _scriptTextMeta),
      );
    } else if (isInserting) {
      context.missing(_scriptTextMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceUrl},
  ];
  @override
  ReadingDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      sourceTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_title'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      scriptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}script_text'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}published_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ReadingDocumentsTable createAlias(String alias) {
    return $ReadingDocumentsTable(attachedDatabase, alias);
  }
}

class ReadingDocument extends DataClass implements Insertable<ReadingDocument> {
  final int id;
  final String sourceUrl;
  final String sourceTitle;
  final String? sourceName;
  final String? description;
  final String scriptText;
  final int? publishedAt;
  final int createdAt;
  final int? updatedAt;
  const ReadingDocument({
    required this.id,
    required this.sourceUrl,
    required this.sourceTitle,
    this.sourceName,
    this.description,
    required this.scriptText,
    this.publishedAt,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_url'] = Variable<String>(sourceUrl);
    map['source_title'] = Variable<String>(sourceTitle);
    if (!nullToAbsent || sourceName != null) {
      map['source_name'] = Variable<String>(sourceName);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['script_text'] = Variable<String>(scriptText);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<int>(publishedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  ReadingDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ReadingDocumentsCompanion(
      id: Value(id),
      sourceUrl: Value(sourceUrl),
      sourceTitle: Value(sourceTitle),
      sourceName: sourceName == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      scriptText: Value(scriptText),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ReadingDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingDocument(
      id: serializer.fromJson<int>(json['id']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      sourceTitle: serializer.fromJson<String>(json['sourceTitle']),
      sourceName: serializer.fromJson<String?>(json['sourceName']),
      description: serializer.fromJson<String?>(json['description']),
      scriptText: serializer.fromJson<String>(json['scriptText']),
      publishedAt: serializer.fromJson<int?>(json['publishedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'sourceTitle': serializer.toJson<String>(sourceTitle),
      'sourceName': serializer.toJson<String?>(sourceName),
      'description': serializer.toJson<String?>(description),
      'scriptText': serializer.toJson<String>(scriptText),
      'publishedAt': serializer.toJson<int?>(publishedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  ReadingDocument copyWith({
    int? id,
    String? sourceUrl,
    String? sourceTitle,
    Value<String?> sourceName = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? scriptText,
    Value<int?> publishedAt = const Value.absent(),
    int? createdAt,
    Value<int?> updatedAt = const Value.absent(),
  }) => ReadingDocument(
    id: id ?? this.id,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    sourceTitle: sourceTitle ?? this.sourceTitle,
    sourceName: sourceName.present ? sourceName.value : this.sourceName,
    description: description.present ? description.value : this.description,
    scriptText: scriptText ?? this.scriptText,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ReadingDocument copyWithCompanion(ReadingDocumentsCompanion data) {
    return ReadingDocument(
      id: data.id.present ? data.id.value : this.id,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      sourceTitle: data.sourceTitle.present
          ? data.sourceTitle.value
          : this.sourceTitle,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      description: data.description.present
          ? data.description.value
          : this.description,
      scriptText: data.scriptText.present
          ? data.scriptText.value
          : this.scriptText,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingDocument(')
          ..write('id: $id, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('sourceName: $sourceName, ')
          ..write('description: $description, ')
          ..write('scriptText: $scriptText, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceUrl,
    sourceTitle,
    sourceName,
    description,
    scriptText,
    publishedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingDocument &&
          other.id == this.id &&
          other.sourceUrl == this.sourceUrl &&
          other.sourceTitle == this.sourceTitle &&
          other.sourceName == this.sourceName &&
          other.description == this.description &&
          other.scriptText == this.scriptText &&
          other.publishedAt == this.publishedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReadingDocumentsCompanion extends UpdateCompanion<ReadingDocument> {
  final Value<int> id;
  final Value<String> sourceUrl;
  final Value<String> sourceTitle;
  final Value<String?> sourceName;
  final Value<String?> description;
  final Value<String> scriptText;
  final Value<int?> publishedAt;
  final Value<int> createdAt;
  final Value<int?> updatedAt;
  const ReadingDocumentsCompanion({
    this.id = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.description = const Value.absent(),
    this.scriptText = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReadingDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceUrl,
    required String sourceTitle,
    this.sourceName = const Value.absent(),
    this.description = const Value.absent(),
    required String scriptText,
    this.publishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : sourceUrl = Value(sourceUrl),
       sourceTitle = Value(sourceTitle),
       scriptText = Value(scriptText);
  static Insertable<ReadingDocument> custom({
    Expression<int>? id,
    Expression<String>? sourceUrl,
    Expression<String>? sourceTitle,
    Expression<String>? sourceName,
    Expression<String>? description,
    Expression<String>? scriptText,
    Expression<int>? publishedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (sourceTitle != null) 'source_title': sourceTitle,
      if (sourceName != null) 'source_name': sourceName,
      if (description != null) 'description': description,
      if (scriptText != null) 'script_text': scriptText,
      if (publishedAt != null) 'published_at': publishedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReadingDocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceUrl,
    Value<String>? sourceTitle,
    Value<String?>? sourceName,
    Value<String?>? description,
    Value<String>? scriptText,
    Value<int?>? publishedAt,
    Value<int>? createdAt,
    Value<int?>? updatedAt,
  }) {
    return ReadingDocumentsCompanion(
      id: id ?? this.id,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      sourceName: sourceName ?? this.sourceName,
      description: description ?? this.description,
      scriptText: scriptText ?? this.scriptText,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (sourceTitle.present) {
      map['source_title'] = Variable<String>(sourceTitle.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (scriptText.present) {
      map['script_text'] = Variable<String>(scriptText.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<int>(publishedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('sourceName: $sourceName, ')
          ..write('description: $description, ')
          ..write('scriptText: $scriptText, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingNotesTable extends ReadingNotes
    with TableInfo<$ReadingNotesTable, ReadingNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reading_documents (id)',
    ),
  );
  static const VerificationMeta _noteTypeMeta = const VerificationMeta(
    'noteType',
  );
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
    'note_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surfaceTextMeta = const VerificationMeta(
    'surfaceText',
  );
  @override
  late final GeneratedColumn<String> surfaceText = GeneratedColumn<String>(
    'surface_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTextMeta = const VerificationMeta(
    'normalizedText',
  );
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
    'normalized_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextSnippetMeta = const VerificationMeta(
    'contextSnippet',
  );
  @override
  late final GeneratedColumn<String> contextSnippet = GeneratedColumn<String>(
    'context_snippet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    noteType,
    surfaceText,
    normalizedText,
    meaning,
    explanation,
    contextSnippet,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('note_type')) {
      context.handle(
        _noteTypeMeta,
        noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_noteTypeMeta);
    }
    if (data.containsKey('surface_text')) {
      context.handle(
        _surfaceTextMeta,
        surfaceText.isAcceptableOrUnknown(
          data['surface_text']!,
          _surfaceTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surfaceTextMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
        _normalizedTextMeta,
        normalizedText.isAcceptableOrUnknown(
          data['normalized_text']!,
          _normalizedTextMeta,
        ),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('context_snippet')) {
      context.handle(
        _contextSnippetMeta,
        contextSnippet.isAcceptableOrUnknown(
          data['context_snippet']!,
          _contextSnippetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      noteType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_type'],
      )!,
      surfaceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface_text'],
      )!,
      normalizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_text'],
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      contextSnippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_snippet'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReadingNotesTable createAlias(String alias) {
    return $ReadingNotesTable(attachedDatabase, alias);
  }
}

class ReadingNote extends DataClass implements Insertable<ReadingNote> {
  final int id;
  final int documentId;
  final String noteType;
  final String surfaceText;
  final String? normalizedText;
  final String? meaning;
  final String? explanation;
  final String? contextSnippet;
  final int createdAt;
  const ReadingNote({
    required this.id,
    required this.documentId,
    required this.noteType,
    required this.surfaceText,
    this.normalizedText,
    this.meaning,
    this.explanation,
    this.contextSnippet,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['note_type'] = Variable<String>(noteType);
    map['surface_text'] = Variable<String>(surfaceText);
    if (!nullToAbsent || normalizedText != null) {
      map['normalized_text'] = Variable<String>(normalizedText);
    }
    if (!nullToAbsent || meaning != null) {
      map['meaning'] = Variable<String>(meaning);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    if (!nullToAbsent || contextSnippet != null) {
      map['context_snippet'] = Variable<String>(contextSnippet);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ReadingNotesCompanion toCompanion(bool nullToAbsent) {
    return ReadingNotesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      noteType: Value(noteType),
      surfaceText: Value(surfaceText),
      normalizedText: normalizedText == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedText),
      meaning: meaning == null && nullToAbsent
          ? const Value.absent()
          : Value(meaning),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      contextSnippet: contextSnippet == null && nullToAbsent
          ? const Value.absent()
          : Value(contextSnippet),
      createdAt: Value(createdAt),
    );
  }

  factory ReadingNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingNote(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      noteType: serializer.fromJson<String>(json['noteType']),
      surfaceText: serializer.fromJson<String>(json['surfaceText']),
      normalizedText: serializer.fromJson<String?>(json['normalizedText']),
      meaning: serializer.fromJson<String?>(json['meaning']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      contextSnippet: serializer.fromJson<String?>(json['contextSnippet']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'noteType': serializer.toJson<String>(noteType),
      'surfaceText': serializer.toJson<String>(surfaceText),
      'normalizedText': serializer.toJson<String?>(normalizedText),
      'meaning': serializer.toJson<String?>(meaning),
      'explanation': serializer.toJson<String?>(explanation),
      'contextSnippet': serializer.toJson<String?>(contextSnippet),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ReadingNote copyWith({
    int? id,
    int? documentId,
    String? noteType,
    String? surfaceText,
    Value<String?> normalizedText = const Value.absent(),
    Value<String?> meaning = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
    Value<String?> contextSnippet = const Value.absent(),
    int? createdAt,
  }) => ReadingNote(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    noteType: noteType ?? this.noteType,
    surfaceText: surfaceText ?? this.surfaceText,
    normalizedText: normalizedText.present
        ? normalizedText.value
        : this.normalizedText,
    meaning: meaning.present ? meaning.value : this.meaning,
    explanation: explanation.present ? explanation.value : this.explanation,
    contextSnippet: contextSnippet.present
        ? contextSnippet.value
        : this.contextSnippet,
    createdAt: createdAt ?? this.createdAt,
  );
  ReadingNote copyWithCompanion(ReadingNotesCompanion data) {
    return ReadingNote(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      surfaceText: data.surfaceText.present
          ? data.surfaceText.value
          : this.surfaceText,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      contextSnippet: data.contextSnippet.present
          ? data.contextSnippet.value
          : this.contextSnippet,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingNote(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('noteType: $noteType, ')
          ..write('surfaceText: $surfaceText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('meaning: $meaning, ')
          ..write('explanation: $explanation, ')
          ..write('contextSnippet: $contextSnippet, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    noteType,
    surfaceText,
    normalizedText,
    meaning,
    explanation,
    contextSnippet,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingNote &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.noteType == this.noteType &&
          other.surfaceText == this.surfaceText &&
          other.normalizedText == this.normalizedText &&
          other.meaning == this.meaning &&
          other.explanation == this.explanation &&
          other.contextSnippet == this.contextSnippet &&
          other.createdAt == this.createdAt);
}

class ReadingNotesCompanion extends UpdateCompanion<ReadingNote> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<String> noteType;
  final Value<String> surfaceText;
  final Value<String?> normalizedText;
  final Value<String?> meaning;
  final Value<String?> explanation;
  final Value<String?> contextSnippet;
  final Value<int> createdAt;
  const ReadingNotesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.noteType = const Value.absent(),
    this.surfaceText = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.meaning = const Value.absent(),
    this.explanation = const Value.absent(),
    this.contextSnippet = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReadingNotesCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required String noteType,
    required String surfaceText,
    this.normalizedText = const Value.absent(),
    this.meaning = const Value.absent(),
    this.explanation = const Value.absent(),
    this.contextSnippet = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : documentId = Value(documentId),
       noteType = Value(noteType),
       surfaceText = Value(surfaceText);
  static Insertable<ReadingNote> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<String>? noteType,
    Expression<String>? surfaceText,
    Expression<String>? normalizedText,
    Expression<String>? meaning,
    Expression<String>? explanation,
    Expression<String>? contextSnippet,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (noteType != null) 'note_type': noteType,
      if (surfaceText != null) 'surface_text': surfaceText,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (meaning != null) 'meaning': meaning,
      if (explanation != null) 'explanation': explanation,
      if (contextSnippet != null) 'context_snippet': contextSnippet,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReadingNotesCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<String>? noteType,
    Value<String>? surfaceText,
    Value<String?>? normalizedText,
    Value<String?>? meaning,
    Value<String?>? explanation,
    Value<String?>? contextSnippet,
    Value<int>? createdAt,
  }) {
    return ReadingNotesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      noteType: noteType ?? this.noteType,
      surfaceText: surfaceText ?? this.surfaceText,
      normalizedText: normalizedText ?? this.normalizedText,
      meaning: meaning ?? this.meaning,
      explanation: explanation ?? this.explanation,
      contextSnippet: contextSnippet ?? this.contextSnippet,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (surfaceText.present) {
      map['surface_text'] = Variable<String>(surfaceText.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (contextSnippet.present) {
      map['context_snippet'] = Variable<String>(contextSnippet.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingNotesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('noteType: $noteType, ')
          ..write('surfaceText: $surfaceText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('meaning: $meaning, ')
          ..write('explanation: $explanation, ')
          ..write('contextSnippet: $contextSnippet, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NewsCacheEntriesTable extends NewsCacheEntries
    with TableInfo<$NewsCacheEntriesTable, NewsCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewsCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().millisecondsSinceEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cacheKey, payloadJson, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'news_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<NewsCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cacheKey},
  ];
  @override
  NewsCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NewsCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $NewsCacheEntriesTable createAlias(String alias) {
    return $NewsCacheEntriesTable(attachedDatabase, alias);
  }
}

class NewsCacheEntry extends DataClass implements Insertable<NewsCacheEntry> {
  final int id;
  final String cacheKey;
  final String payloadJson;
  final int fetchedAt;
  const NewsCacheEntry({
    required this.id,
    required this.cacheKey,
    required this.payloadJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  NewsCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return NewsCacheEntriesCompanion(
      id: Value(id),
      cacheKey: Value(cacheKey),
      payloadJson: Value(payloadJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory NewsCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NewsCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  NewsCacheEntry copyWith({
    int? id,
    String? cacheKey,
    String? payloadJson,
    int? fetchedAt,
  }) => NewsCacheEntry(
    id: id ?? this.id,
    cacheKey: cacheKey ?? this.cacheKey,
    payloadJson: payloadJson ?? this.payloadJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  NewsCacheEntry copyWithCompanion(NewsCacheEntriesCompanion data) {
    return NewsCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NewsCacheEntry(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cacheKey, payloadJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NewsCacheEntry &&
          other.id == this.id &&
          other.cacheKey == this.cacheKey &&
          other.payloadJson == this.payloadJson &&
          other.fetchedAt == this.fetchedAt);
}

class NewsCacheEntriesCompanion extends UpdateCompanion<NewsCacheEntry> {
  final Value<int> id;
  final Value<String> cacheKey;
  final Value<String> payloadJson;
  final Value<int> fetchedAt;
  const NewsCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  NewsCacheEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String cacheKey,
    required String payloadJson,
    this.fetchedAt = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       payloadJson = Value(payloadJson);
  static Insertable<NewsCacheEntry> custom({
    Expression<int>? id,
    Expression<String>? cacheKey,
    Expression<String>? payloadJson,
    Expression<int>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  NewsCacheEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? cacheKey,
    Value<String>? payloadJson,
    Value<int>? fetchedAt,
  }) {
    return NewsCacheEntriesCompanion(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      payloadJson: payloadJson ?? this.payloadJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewsCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabWordsTable vocabWords = $VocabWordsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $ReadingDocumentsTable readingDocuments = $ReadingDocumentsTable(
    this,
  );
  late final $ReadingNotesTable readingNotes = $ReadingNotesTable(this);
  late final $NewsCacheEntriesTable newsCacheEntries = $NewsCacheEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabWords,
    studySessions,
    readingDocuments,
    readingNotes,
    newsCacheEntries,
  ];
}

typedef $$VocabWordsTableCreateCompanionBuilder =
    VocabWordsCompanion Function({
      Value<int> id,
      required String german,
      Value<String?> article,
      Value<String> partOfSpeech,
      required String meaningEn,
      required String meaningKo,
      required String pronunciation,
      Value<String> ttsLocale,
      required String exampleSentence,
      required String exampleTranslation,
      Value<String?> grammarNote,
      Value<String> deck,
      Value<int> difficulty,
      Value<int> mastery,
      Value<bool> isBookmarked,
      Value<int> timesReviewed,
      Value<int?> nextReviewAt,
      Value<int?> lastReviewedAt,
      Value<bool> isDailyRecommendation,
      Value<String?> dailyRecommendationDateKey,
      Value<int> createdAt,
    });
typedef $$VocabWordsTableUpdateCompanionBuilder =
    VocabWordsCompanion Function({
      Value<int> id,
      Value<String> german,
      Value<String?> article,
      Value<String> partOfSpeech,
      Value<String> meaningEn,
      Value<String> meaningKo,
      Value<String> pronunciation,
      Value<String> ttsLocale,
      Value<String> exampleSentence,
      Value<String> exampleTranslation,
      Value<String?> grammarNote,
      Value<String> deck,
      Value<int> difficulty,
      Value<int> mastery,
      Value<bool> isBookmarked,
      Value<int> timesReviewed,
      Value<int?> nextReviewAt,
      Value<int?> lastReviewedAt,
      Value<bool> isDailyRecommendation,
      Value<String?> dailyRecommendationDateKey,
      Value<int> createdAt,
    });

class $$VocabWordsTableFilterComposer
    extends Composer<_$AppDatabase, $VocabWordsTable> {
  $$VocabWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get german => $composableBuilder(
    column: $table.german,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get article => $composableBuilder(
    column: $table.article,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningKo => $composableBuilder(
    column: $table.meaningKo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttsLocale => $composableBuilder(
    column: $table.ttsLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarNote => $composableBuilder(
    column: $table.grammarNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deck => $composableBuilder(
    column: $table.deck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mastery => $composableBuilder(
    column: $table.mastery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesReviewed => $composableBuilder(
    column: $table.timesReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDailyRecommendation => $composableBuilder(
    column: $table.isDailyRecommendation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyRecommendationDateKey => $composableBuilder(
    column: $table.dailyRecommendationDateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VocabWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabWordsTable> {
  $$VocabWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get german => $composableBuilder(
    column: $table.german,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get article => $composableBuilder(
    column: $table.article,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningKo => $composableBuilder(
    column: $table.meaningKo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsLocale => $composableBuilder(
    column: $table.ttsLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarNote => $composableBuilder(
    column: $table.grammarNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deck => $composableBuilder(
    column: $table.deck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mastery => $composableBuilder(
    column: $table.mastery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesReviewed => $composableBuilder(
    column: $table.timesReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDailyRecommendation => $composableBuilder(
    column: $table.isDailyRecommendation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyRecommendationDateKey => $composableBuilder(
    column: $table.dailyRecommendationDateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabWordsTable> {
  $$VocabWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get german =>
      $composableBuilder(column: $table.german, builder: (column) => column);

  GeneratedColumn<String> get article =>
      $composableBuilder(column: $table.article, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get meaningKo =>
      $composableBuilder(column: $table.meaningKo, builder: (column) => column);

  GeneratedColumn<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ttsLocale =>
      $composableBuilder(column: $table.ttsLocale, builder: (column) => column);

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammarNote => $composableBuilder(
    column: $table.grammarNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deck =>
      $composableBuilder(column: $table.deck, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mastery =>
      $composableBuilder(column: $table.mastery, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesReviewed => $composableBuilder(
    column: $table.timesReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDailyRecommendation => $composableBuilder(
    column: $table.isDailyRecommendation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyRecommendationDateKey => $composableBuilder(
    column: $table.dailyRecommendationDateKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VocabWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabWordsTable,
          VocabWord,
          $$VocabWordsTableFilterComposer,
          $$VocabWordsTableOrderingComposer,
          $$VocabWordsTableAnnotationComposer,
          $$VocabWordsTableCreateCompanionBuilder,
          $$VocabWordsTableUpdateCompanionBuilder,
          (
            VocabWord,
            BaseReferences<_$AppDatabase, $VocabWordsTable, VocabWord>,
          ),
          VocabWord,
          PrefetchHooks Function()
        > {
  $$VocabWordsTableTableManager(_$AppDatabase db, $VocabWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> german = const Value.absent(),
                Value<String?> article = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> meaningEn = const Value.absent(),
                Value<String> meaningKo = const Value.absent(),
                Value<String> pronunciation = const Value.absent(),
                Value<String> ttsLocale = const Value.absent(),
                Value<String> exampleSentence = const Value.absent(),
                Value<String> exampleTranslation = const Value.absent(),
                Value<String?> grammarNote = const Value.absent(),
                Value<String> deck = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> mastery = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<int> timesReviewed = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<bool> isDailyRecommendation = const Value.absent(),
                Value<String?> dailyRecommendationDateKey =
                    const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => VocabWordsCompanion(
                id: id,
                german: german,
                article: article,
                partOfSpeech: partOfSpeech,
                meaningEn: meaningEn,
                meaningKo: meaningKo,
                pronunciation: pronunciation,
                ttsLocale: ttsLocale,
                exampleSentence: exampleSentence,
                exampleTranslation: exampleTranslation,
                grammarNote: grammarNote,
                deck: deck,
                difficulty: difficulty,
                mastery: mastery,
                isBookmarked: isBookmarked,
                timesReviewed: timesReviewed,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
                isDailyRecommendation: isDailyRecommendation,
                dailyRecommendationDateKey: dailyRecommendationDateKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String german,
                Value<String?> article = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                required String meaningEn,
                required String meaningKo,
                required String pronunciation,
                Value<String> ttsLocale = const Value.absent(),
                required String exampleSentence,
                required String exampleTranslation,
                Value<String?> grammarNote = const Value.absent(),
                Value<String> deck = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> mastery = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<int> timesReviewed = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<bool> isDailyRecommendation = const Value.absent(),
                Value<String?> dailyRecommendationDateKey =
                    const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => VocabWordsCompanion.insert(
                id: id,
                german: german,
                article: article,
                partOfSpeech: partOfSpeech,
                meaningEn: meaningEn,
                meaningKo: meaningKo,
                pronunciation: pronunciation,
                ttsLocale: ttsLocale,
                exampleSentence: exampleSentence,
                exampleTranslation: exampleTranslation,
                grammarNote: grammarNote,
                deck: deck,
                difficulty: difficulty,
                mastery: mastery,
                isBookmarked: isBookmarked,
                timesReviewed: timesReviewed,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
                isDailyRecommendation: isDailyRecommendation,
                dailyRecommendationDateKey: dailyRecommendationDateKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VocabWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabWordsTable,
      VocabWord,
      $$VocabWordsTableFilterComposer,
      $$VocabWordsTableOrderingComposer,
      $$VocabWordsTableAnnotationComposer,
      $$VocabWordsTableCreateCompanionBuilder,
      $$VocabWordsTableUpdateCompanionBuilder,
      (VocabWord, BaseReferences<_$AppDatabase, $VocabWordsTable, VocabWord>),
      VocabWord,
      PrefetchHooks Function()
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<int> id,
      required int studiedAt,
      Value<int> reviewedCount,
      Value<int> masteredCount,
      Value<int> minutesSpent,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<int> id,
      Value<int> studiedAt,
      Value<int> reviewedCount,
      Value<int> masteredCount,
      Value<int> minutesSpent,
    });

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studiedAt => $composableBuilder(
    column: $table.studiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedCount => $composableBuilder(
    column: $table.reviewedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get masteredCount => $composableBuilder(
    column: $table.masteredCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesSpent => $composableBuilder(
    column: $table.minutesSpent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studiedAt => $composableBuilder(
    column: $table.studiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedCount => $composableBuilder(
    column: $table.reviewedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get masteredCount => $composableBuilder(
    column: $table.masteredCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesSpent => $composableBuilder(
    column: $table.minutesSpent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studiedAt =>
      $composableBuilder(column: $table.studiedAt, builder: (column) => column);

  GeneratedColumn<int> get reviewedCount => $composableBuilder(
    column: $table.reviewedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get masteredCount => $composableBuilder(
    column: $table.masteredCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutesSpent => $composableBuilder(
    column: $table.minutesSpent,
    builder: (column) => column,
  );
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (
            StudySession,
            BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
          ),
          StudySession,
          PrefetchHooks Function()
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studiedAt = const Value.absent(),
                Value<int> reviewedCount = const Value.absent(),
                Value<int> masteredCount = const Value.absent(),
                Value<int> minutesSpent = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                studiedAt: studiedAt,
                reviewedCount: reviewedCount,
                masteredCount: masteredCount,
                minutesSpent: minutesSpent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studiedAt,
                Value<int> reviewedCount = const Value.absent(),
                Value<int> masteredCount = const Value.absent(),
                Value<int> minutesSpent = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                studiedAt: studiedAt,
                reviewedCount: reviewedCount,
                masteredCount: masteredCount,
                minutesSpent: minutesSpent,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (
        StudySession,
        BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>,
      ),
      StudySession,
      PrefetchHooks Function()
    >;
typedef $$ReadingDocumentsTableCreateCompanionBuilder =
    ReadingDocumentsCompanion Function({
      Value<int> id,
      required String sourceUrl,
      required String sourceTitle,
      Value<String?> sourceName,
      Value<String?> description,
      required String scriptText,
      Value<int?> publishedAt,
      Value<int> createdAt,
      Value<int?> updatedAt,
    });
typedef $$ReadingDocumentsTableUpdateCompanionBuilder =
    ReadingDocumentsCompanion Function({
      Value<int> id,
      Value<String> sourceUrl,
      Value<String> sourceTitle,
      Value<String?> sourceName,
      Value<String?> description,
      Value<String> scriptText,
      Value<int?> publishedAt,
      Value<int> createdAt,
      Value<int?> updatedAt,
    });

final class $$ReadingDocumentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReadingDocumentsTable, ReadingDocument> {
  $$ReadingDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ReadingNotesTable, List<ReadingNote>>
  _readingNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingNotes,
    aliasName: $_aliasNameGenerator(
      db.readingDocuments.id,
      db.readingNotes.documentId,
    ),
  );

  $$ReadingNotesTableProcessedTableManager get readingNotesRefs {
    final manager = $$ReadingNotesTableTableManager(
      $_db,
      $_db.readingNotes,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReadingDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingDocumentsTable> {
  $$ReadingDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scriptText => $composableBuilder(
    column: $table.scriptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> readingNotesRefs(
    Expression<bool> Function($$ReadingNotesTableFilterComposer f) f,
  ) {
    final $$ReadingNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingNotes,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingNotesTableFilterComposer(
            $db: $db,
            $table: $db.readingNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReadingDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingDocumentsTable> {
  $$ReadingDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scriptText => $composableBuilder(
    column: $table.scriptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingDocumentsTable> {
  $$ReadingDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scriptText => $composableBuilder(
    column: $table.scriptText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> readingNotesRefs<T extends Object>(
    Expression<T> Function($$ReadingNotesTableAnnotationComposer a) f,
  ) {
    final $$ReadingNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingNotes,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.readingNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReadingDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingDocumentsTable,
          ReadingDocument,
          $$ReadingDocumentsTableFilterComposer,
          $$ReadingDocumentsTableOrderingComposer,
          $$ReadingDocumentsTableAnnotationComposer,
          $$ReadingDocumentsTableCreateCompanionBuilder,
          $$ReadingDocumentsTableUpdateCompanionBuilder,
          (ReadingDocument, $$ReadingDocumentsTableReferences),
          ReadingDocument,
          PrefetchHooks Function({bool readingNotesRefs})
        > {
  $$ReadingDocumentsTableTableManager(
    _$AppDatabase db,
    $ReadingDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> sourceTitle = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> scriptText = const Value.absent(),
                Value<int?> publishedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => ReadingDocumentsCompanion(
                id: id,
                sourceUrl: sourceUrl,
                sourceTitle: sourceTitle,
                sourceName: sourceName,
                description: description,
                scriptText: scriptText,
                publishedAt: publishedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceUrl,
                required String sourceTitle,
                Value<String?> sourceName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String scriptText,
                Value<int?> publishedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => ReadingDocumentsCompanion.insert(
                id: id,
                sourceUrl: sourceUrl,
                sourceTitle: sourceTitle,
                sourceName: sourceName,
                description: description,
                scriptText: scriptText,
                publishedAt: publishedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({readingNotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (readingNotesRefs) db.readingNotes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingNotesRefs)
                    await $_getPrefetchedData<
                      ReadingDocument,
                      $ReadingDocumentsTable,
                      ReadingNote
                    >(
                      currentTable: table,
                      referencedTable: $$ReadingDocumentsTableReferences
                          ._readingNotesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReadingDocumentsTableReferences(
                            db,
                            table,
                            p0,
                          ).readingNotesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.documentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReadingDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingDocumentsTable,
      ReadingDocument,
      $$ReadingDocumentsTableFilterComposer,
      $$ReadingDocumentsTableOrderingComposer,
      $$ReadingDocumentsTableAnnotationComposer,
      $$ReadingDocumentsTableCreateCompanionBuilder,
      $$ReadingDocumentsTableUpdateCompanionBuilder,
      (ReadingDocument, $$ReadingDocumentsTableReferences),
      ReadingDocument,
      PrefetchHooks Function({bool readingNotesRefs})
    >;
typedef $$ReadingNotesTableCreateCompanionBuilder =
    ReadingNotesCompanion Function({
      Value<int> id,
      required int documentId,
      required String noteType,
      required String surfaceText,
      Value<String?> normalizedText,
      Value<String?> meaning,
      Value<String?> explanation,
      Value<String?> contextSnippet,
      Value<int> createdAt,
    });
typedef $$ReadingNotesTableUpdateCompanionBuilder =
    ReadingNotesCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<String> noteType,
      Value<String> surfaceText,
      Value<String?> normalizedText,
      Value<String?> meaning,
      Value<String?> explanation,
      Value<String?> contextSnippet,
      Value<int> createdAt,
    });

final class $$ReadingNotesTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingNotesTable, ReadingNote> {
  $$ReadingNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReadingDocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.readingDocuments.createAlias(
        $_aliasNameGenerator(
          db.readingNotes.documentId,
          db.readingDocuments.id,
        ),
      );

  $$ReadingDocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$ReadingDocumentsTableTableManager(
      $_db,
      $_db.readingDocuments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingNotesTable> {
  $$ReadingNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfaceText => $composableBuilder(
    column: $table.surfaceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSnippet => $composableBuilder(
    column: $table.contextSnippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ReadingDocumentsTableFilterComposer get documentId {
    final $$ReadingDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.readingDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.readingDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingNotesTable> {
  $$ReadingNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfaceText => $composableBuilder(
    column: $table.surfaceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSnippet => $composableBuilder(
    column: $table.contextSnippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReadingDocumentsTableOrderingComposer get documentId {
    final $$ReadingDocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.readingDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingDocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.readingDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingNotesTable> {
  $$ReadingNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<String> get surfaceText => $composableBuilder(
    column: $table.surfaceText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextSnippet => $composableBuilder(
    column: $table.contextSnippet,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ReadingDocumentsTableAnnotationComposer get documentId {
    final $$ReadingDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.readingDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingNotesTable,
          ReadingNote,
          $$ReadingNotesTableFilterComposer,
          $$ReadingNotesTableOrderingComposer,
          $$ReadingNotesTableAnnotationComposer,
          $$ReadingNotesTableCreateCompanionBuilder,
          $$ReadingNotesTableUpdateCompanionBuilder,
          (ReadingNote, $$ReadingNotesTableReferences),
          ReadingNote,
          PrefetchHooks Function({bool documentId})
        > {
  $$ReadingNotesTableTableManager(_$AppDatabase db, $ReadingNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<String> noteType = const Value.absent(),
                Value<String> surfaceText = const Value.absent(),
                Value<String?> normalizedText = const Value.absent(),
                Value<String?> meaning = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> contextSnippet = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => ReadingNotesCompanion(
                id: id,
                documentId: documentId,
                noteType: noteType,
                surfaceText: surfaceText,
                normalizedText: normalizedText,
                meaning: meaning,
                explanation: explanation,
                contextSnippet: contextSnippet,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required String noteType,
                required String surfaceText,
                Value<String?> normalizedText = const Value.absent(),
                Value<String?> meaning = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> contextSnippet = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => ReadingNotesCompanion.insert(
                id: id,
                documentId: documentId,
                noteType: noteType,
                surfaceText: surfaceText,
                normalizedText: normalizedText,
                meaning: meaning,
                explanation: explanation,
                contextSnippet: contextSnippet,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable: $$ReadingNotesTableReferences
                                    ._documentIdTable(db),
                                referencedColumn: $$ReadingNotesTableReferences
                                    ._documentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingNotesTable,
      ReadingNote,
      $$ReadingNotesTableFilterComposer,
      $$ReadingNotesTableOrderingComposer,
      $$ReadingNotesTableAnnotationComposer,
      $$ReadingNotesTableCreateCompanionBuilder,
      $$ReadingNotesTableUpdateCompanionBuilder,
      (ReadingNote, $$ReadingNotesTableReferences),
      ReadingNote,
      PrefetchHooks Function({bool documentId})
    >;
typedef $$NewsCacheEntriesTableCreateCompanionBuilder =
    NewsCacheEntriesCompanion Function({
      Value<int> id,
      required String cacheKey,
      required String payloadJson,
      Value<int> fetchedAt,
    });
typedef $$NewsCacheEntriesTableUpdateCompanionBuilder =
    NewsCacheEntriesCompanion Function({
      Value<int> id,
      Value<String> cacheKey,
      Value<String> payloadJson,
      Value<int> fetchedAt,
    });

class $$NewsCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $NewsCacheEntriesTable> {
  $$NewsCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NewsCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $NewsCacheEntriesTable> {
  $$NewsCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NewsCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewsCacheEntriesTable> {
  $$NewsCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$NewsCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NewsCacheEntriesTable,
          NewsCacheEntry,
          $$NewsCacheEntriesTableFilterComposer,
          $$NewsCacheEntriesTableOrderingComposer,
          $$NewsCacheEntriesTableAnnotationComposer,
          $$NewsCacheEntriesTableCreateCompanionBuilder,
          $$NewsCacheEntriesTableUpdateCompanionBuilder,
          (
            NewsCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $NewsCacheEntriesTable,
              NewsCacheEntry
            >,
          ),
          NewsCacheEntry,
          PrefetchHooks Function()
        > {
  $$NewsCacheEntriesTableTableManager(
    _$AppDatabase db,
    $NewsCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewsCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewsCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NewsCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
              }) => NewsCacheEntriesCompanion(
                id: id,
                cacheKey: cacheKey,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cacheKey,
                required String payloadJson,
                Value<int> fetchedAt = const Value.absent(),
              }) => NewsCacheEntriesCompanion.insert(
                id: id,
                cacheKey: cacheKey,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NewsCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NewsCacheEntriesTable,
      NewsCacheEntry,
      $$NewsCacheEntriesTableFilterComposer,
      $$NewsCacheEntriesTableOrderingComposer,
      $$NewsCacheEntriesTableAnnotationComposer,
      $$NewsCacheEntriesTableCreateCompanionBuilder,
      $$NewsCacheEntriesTableUpdateCompanionBuilder,
      (
        NewsCacheEntry,
        BaseReferences<_$AppDatabase, $NewsCacheEntriesTable, NewsCacheEntry>,
      ),
      NewsCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabWordsTableTableManager get vocabWords =>
      $$VocabWordsTableTableManager(_db, _db.vocabWords);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$ReadingDocumentsTableTableManager get readingDocuments =>
      $$ReadingDocumentsTableTableManager(_db, _db.readingDocuments);
  $$ReadingNotesTableTableManager get readingNotes =>
      $$ReadingNotesTableTableManager(_db, _db.readingNotes);
  $$NewsCacheEntriesTableTableManager get newsCacheEntries =>
      $$NewsCacheEntriesTableTableManager(_db, _db.newsCacheEntries);
}
