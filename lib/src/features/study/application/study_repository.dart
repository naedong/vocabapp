import 'dart:convert';

import '../../../core/database/app_database.dart';
import 'practice_exam_models.dart';

class StudyRepository {
  const StudyRepository(this.database);

  final AppDatabase database;

  Stream<List<VocabWord>> watchWords() => database.watchWords();

  Stream<List<StudySession>> watchStudySessions() =>
      database.watchStudySessions();

  Stream<List<SavedPracticeExamSet>> watchSavedPracticeExamSets({
    required String languageCode,
  }) {
    return database.watchPracticeExamEntries(languageCode).map((entries) {
      final savedSets = <SavedPracticeExamSet>[];

      for (final entry in entries) {
        try {
          final decoded = jsonDecode(entry.payloadJson);
          if (decoded is! Map<String, dynamic>) {
            continue;
          }
          savedSets.add(
            SavedPracticeExamSet(
              id: entry.id,
              set: PracticeExamSet.fromJson(decoded),
              createdAt: DateTime.fromMillisecondsSinceEpoch(entry.createdAt),
              updatedAt: entry.updatedAt == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(entry.updatedAt!),
            ),
          );
        } catch (_) {
          continue;
        }
      }

      return savedSets;
    });
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
  }) {
    return database.addWord(
      languageCode: languageCode,
      german: german,
      meaningEn: meaningEn,
      meaningKo: meaningKo,
      pronunciation: pronunciation,
      ttsLocale: ttsLocale,
      article: article,
      partOfSpeech: partOfSpeech,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      deck: deck,
      grammarNote: grammarNote,
      isDailyRecommendation: isDailyRecommendation,
      dailyRecommendationDate: dailyRecommendationDate,
    );
  }

  Future<void> toggleBookmark(VocabWord word) => database.toggleBookmark(word);

  Future<void> updateWordTtsLocale(VocabWord word, String ttsLocale) {
    return database.updateWordTtsLocale(word, ttsLocale);
  }

  Future<bool> savePracticeExamSet(PracticeExamSet set) {
    return database.upsertPracticeExamEntry(
      languageCode: set.languageCode,
      sourceKey: set.sourceKey,
      payloadJson: jsonEncode(set.toJson()),
    );
  }

  Future<void> deletePracticeExamSet(SavedPracticeExamSet savedSet) {
    return database.deletePracticeExamEntry(savedSet.id);
  }

  Future<void> reviewWord(VocabWord word, {required bool remembered}) {
    return database.reviewWord(word, remembered: remembered);
  }
}
