import '../../../core/audio/voice_locale.dart';

class StudyWordDraft {
  const StudyWordDraft({
    required this.german,
    required this.meaningEn,
    required this.meaningKo,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.article,
    this.grammarNote,
    this.deck = '실전 읽기',
    this.ttsLocale = defaultVoiceLocaleCode,
  });

  final String german;
  final String meaningEn;
  final String meaningKo;
  final String pronunciation;
  final String partOfSpeech;
  final String exampleSentence;
  final String exampleTranslation;
  final String? article;
  final String? grammarNote;
  final String deck;
  final String ttsLocale;
}
