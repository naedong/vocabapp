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
    exampleSentence,
    exampleTranslation,
    deck,
    difficulty,
    mastery,
    isBookmarked,
    timesReviewed,
    nextReviewAt,
    lastReviewedAt,
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
      exampleSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_sentence'],
      )!,
      exampleTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_translation'],
      )!,
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
  final String exampleSentence;
  final String exampleTranslation;
  final String deck;
  final int difficulty;
  final int mastery;
  final bool isBookmarked;
  final int timesReviewed;
  final int? nextReviewAt;
  final int? lastReviewedAt;
  final int createdAt;
  const VocabWord({
    required this.id,
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
    required this.isBookmarked,
    required this.timesReviewed,
    this.nextReviewAt,
    this.lastReviewedAt,
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
    map['example_sentence'] = Variable<String>(exampleSentence);
    map['example_translation'] = Variable<String>(exampleTranslation);
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
      exampleSentence: Value(exampleSentence),
      exampleTranslation: Value(exampleTranslation),
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
      exampleSentence: serializer.fromJson<String>(json['exampleSentence']),
      exampleTranslation: serializer.fromJson<String>(
        json['exampleTranslation'],
      ),
      deck: serializer.fromJson<String>(json['deck']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      mastery: serializer.fromJson<int>(json['mastery']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      timesReviewed: serializer.fromJson<int>(json['timesReviewed']),
      nextReviewAt: serializer.fromJson<int?>(json['nextReviewAt']),
      lastReviewedAt: serializer.fromJson<int?>(json['lastReviewedAt']),
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
      'exampleSentence': serializer.toJson<String>(exampleSentence),
      'exampleTranslation': serializer.toJson<String>(exampleTranslation),
      'deck': serializer.toJson<String>(deck),
      'difficulty': serializer.toJson<int>(difficulty),
      'mastery': serializer.toJson<int>(mastery),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'timesReviewed': serializer.toJson<int>(timesReviewed),
      'nextReviewAt': serializer.toJson<int?>(nextReviewAt),
      'lastReviewedAt': serializer.toJson<int?>(lastReviewedAt),
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
    String? exampleSentence,
    String? exampleTranslation,
    String? deck,
    int? difficulty,
    int? mastery,
    bool? isBookmarked,
    int? timesReviewed,
    Value<int?> nextReviewAt = const Value.absent(),
    Value<int?> lastReviewedAt = const Value.absent(),
    int? createdAt,
  }) => VocabWord(
    id: id ?? this.id,
    german: german ?? this.german,
    article: article.present ? article.value : this.article,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    meaningEn: meaningEn ?? this.meaningEn,
    meaningKo: meaningKo ?? this.meaningKo,
    pronunciation: pronunciation ?? this.pronunciation,
    exampleSentence: exampleSentence ?? this.exampleSentence,
    exampleTranslation: exampleTranslation ?? this.exampleTranslation,
    deck: deck ?? this.deck,
    difficulty: difficulty ?? this.difficulty,
    mastery: mastery ?? this.mastery,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    timesReviewed: timesReviewed ?? this.timesReviewed,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
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
      exampleSentence: data.exampleSentence.present
          ? data.exampleSentence.value
          : this.exampleSentence,
      exampleTranslation: data.exampleTranslation.present
          ? data.exampleTranslation.value
          : this.exampleTranslation,
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
          ..write('exampleSentence: $exampleSentence, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('deck: $deck, ')
          ..write('difficulty: $difficulty, ')
          ..write('mastery: $mastery, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    german,
    article,
    partOfSpeech,
    meaningEn,
    meaningKo,
    pronunciation,
    exampleSentence,
    exampleTranslation,
    deck,
    difficulty,
    mastery,
    isBookmarked,
    timesReviewed,
    nextReviewAt,
    lastReviewedAt,
    createdAt,
  );
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
          other.exampleSentence == this.exampleSentence &&
          other.exampleTranslation == this.exampleTranslation &&
          other.deck == this.deck &&
          other.difficulty == this.difficulty &&
          other.mastery == this.mastery &&
          other.isBookmarked == this.isBookmarked &&
          other.timesReviewed == this.timesReviewed &&
          other.nextReviewAt == this.nextReviewAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
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
  final Value<String> exampleSentence;
  final Value<String> exampleTranslation;
  final Value<String> deck;
  final Value<int> difficulty;
  final Value<int> mastery;
  final Value<bool> isBookmarked;
  final Value<int> timesReviewed;
  final Value<int?> nextReviewAt;
  final Value<int?> lastReviewedAt;
  final Value<int> createdAt;
  const VocabWordsCompanion({
    this.id = const Value.absent(),
    this.german = const Value.absent(),
    this.article = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.meaningKo = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.exampleSentence = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.deck = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mastery = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
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
    required String exampleSentence,
    required String exampleTranslation,
    this.deck = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mastery = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
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
    Expression<String>? exampleSentence,
    Expression<String>? exampleTranslation,
    Expression<String>? deck,
    Expression<int>? difficulty,
    Expression<int>? mastery,
    Expression<bool>? isBookmarked,
    Expression<int>? timesReviewed,
    Expression<int>? nextReviewAt,
    Expression<int>? lastReviewedAt,
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
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (exampleTranslation != null) 'example_translation': exampleTranslation,
      if (deck != null) 'deck': deck,
      if (difficulty != null) 'difficulty': difficulty,
      if (mastery != null) 'mastery': mastery,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (timesReviewed != null) 'times_reviewed': timesReviewed,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
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
    Value<String>? exampleSentence,
    Value<String>? exampleTranslation,
    Value<String>? deck,
    Value<int>? difficulty,
    Value<int>? mastery,
    Value<bool>? isBookmarked,
    Value<int>? timesReviewed,
    Value<int?>? nextReviewAt,
    Value<int?>? lastReviewedAt,
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
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      deck: deck ?? this.deck,
      difficulty: difficulty ?? this.difficulty,
      mastery: mastery ?? this.mastery,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
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
    if (exampleSentence.present) {
      map['example_sentence'] = Variable<String>(exampleSentence.value);
    }
    if (exampleTranslation.present) {
      map['example_translation'] = Variable<String>(exampleTranslation.value);
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
          ..write('exampleSentence: $exampleSentence, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('deck: $deck, ')
          ..write('difficulty: $difficulty, ')
          ..write('mastery: $mastery, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VocabWordsTable vocabWords = $VocabWordsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocabWords,
    studySessions,
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
      required String exampleSentence,
      required String exampleTranslation,
      Value<String> deck,
      Value<int> difficulty,
      Value<int> mastery,
      Value<bool> isBookmarked,
      Value<int> timesReviewed,
      Value<int?> nextReviewAt,
      Value<int?> lastReviewedAt,
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
      Value<String> exampleSentence,
      Value<String> exampleTranslation,
      Value<String> deck,
      Value<int> difficulty,
      Value<int> mastery,
      Value<bool> isBookmarked,
      Value<int> timesReviewed,
      Value<int?> nextReviewAt,
      Value<int?> lastReviewedAt,
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

  ColumnFilters<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
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

  ColumnOrderings<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
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

  GeneratedColumn<String> get exampleSentence => $composableBuilder(
    column: $table.exampleSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
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
                Value<String> exampleSentence = const Value.absent(),
                Value<String> exampleTranslation = const Value.absent(),
                Value<String> deck = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> mastery = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<int> timesReviewed = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => VocabWordsCompanion(
                id: id,
                german: german,
                article: article,
                partOfSpeech: partOfSpeech,
                meaningEn: meaningEn,
                meaningKo: meaningKo,
                pronunciation: pronunciation,
                exampleSentence: exampleSentence,
                exampleTranslation: exampleTranslation,
                deck: deck,
                difficulty: difficulty,
                mastery: mastery,
                isBookmarked: isBookmarked,
                timesReviewed: timesReviewed,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
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
                required String exampleSentence,
                required String exampleTranslation,
                Value<String> deck = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> mastery = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<int> timesReviewed = const Value.absent(),
                Value<int?> nextReviewAt = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => VocabWordsCompanion.insert(
                id: id,
                german: german,
                article: article,
                partOfSpeech: partOfSpeech,
                meaningEn: meaningEn,
                meaningKo: meaningKo,
                pronunciation: pronunciation,
                exampleSentence: exampleSentence,
                exampleTranslation: exampleTranslation,
                deck: deck,
                difficulty: difficulty,
                mastery: mastery,
                isBookmarked: isBookmarked,
                timesReviewed: timesReviewed,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VocabWordsTableTableManager get vocabWords =>
      $$VocabWordsTableTableManager(_db, _db.vocabWords);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
}
