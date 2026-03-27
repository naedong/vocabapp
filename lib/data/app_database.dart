import 'package:drift/drift.dart';

import 'db_connection.dart';

class VocabWord {
  const VocabWord({
    required this.id,
    required this.german,
    required this.meaningEn,
    required this.meaningKo,
    required this.pronunciationEn,
    required this.pronunciationKo,
    required this.createdAt,
  });

  final int id;
  final String german;
  final String meaningEn;
  final String meaningKo;
  final String pronunciationEn;
  final String pronunciationKo;
  final DateTime createdAt;

  factory VocabWord.fromRow(QueryRow row) {
    return VocabWord(
      id: row.read<int>('id'),
      german: row.read<String>('german'),
      meaningEn: row.read<String>('meaning_en'),
      meaningKo: row.read<String>('meaning_ko'),
      pronunciationEn: row.read<String>('pronunciation_en'),
      pronunciationKo: row.read<String>('pronunciation_ko'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('created_at'),
      ),
    );
  }
}

class _MinimalDriftDatabase extends GeneratedDatabase {
  _MinimalDriftDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
}

class AppDatabase {
  AppDatabase() : _db = _MinimalDriftDatabase(openConnection());

  final _MinimalDriftDatabase _db;

  Future<void> setup() {
    return _db.customStatement('''
      CREATE TABLE IF NOT EXISTS vocab_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        german TEXT NOT NULL,
        meaning_en TEXT NOT NULL,
        meaning_ko TEXT NOT NULL,
        pronunciation_en TEXT NOT NULL,
        pronunciation_ko TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> addWord({
    required String german,
    required String meaningEn,
    required String meaningKo,
    required String pronunciationEn,
    required String pronunciationKo,
  }) {
    return _db.customStatement(
      '''
      INSERT INTO vocab_words (
        german, meaning_en, meaning_ko, pronunciation_en, pronunciation_ko, created_at
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        german,
        meaningEn,
        meaningKo,
        pronunciationEn,
        pronunciationKo,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<int> countWords() async {
    final result = await _db
        .customSelect('SELECT COUNT(*) AS cnt FROM vocab_words')
        .getSingle();
    return result.read<int>('cnt');
  }

  Stream<List<VocabWord>> watchWords() {
    return _db
        .customSelect('SELECT * FROM vocab_words ORDER BY created_at DESC')
        .watch()
        .map((rows) => rows.map(VocabWord.fromRow).toList());
  }

  Future<void> close() => _db.close();
}
