import '../../../core/database/app_database.dart';

class StudyRepository {
  const StudyRepository(this.database);

  final AppDatabase database;

  Stream<List<VocabWord>> watchWords() => database.watchWords();

  Stream<List<StudySession>> watchStudySessions() =>
      database.watchStudySessions();

  Future<void> addWord({
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

  Future<void> reviewWord(VocabWord word, {required bool remembered}) {
    return database.reviewWord(word, remembered: remembered);
  }
}
