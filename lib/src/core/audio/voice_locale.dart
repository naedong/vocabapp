import '../localization/app_locale.dart';
import '../settings/app_settings.dart';

const String defaultVoiceLocaleCode = 'de-DE';

class VoiceLocaleOption {
  const VoiceLocaleOption({
    required this.code,
    required this.languageLabelKo,
    required this.regionLabelKo,
    required this.languageLabelEn,
    required this.regionLabelEn,
    required this.previewHint,
  });

  final String code;
  final String languageLabelKo;
  final String regionLabelKo;
  final String languageLabelEn;
  final String regionLabelEn;
  final String previewHint;

  String displayLabelFor(AppLanguage appLanguage) {
    return AppLocale.resolveLegacyPair(
      appLanguage.code,
      korean: '$languageLabelKo · $regionLabelKo',
      english: '$languageLabelEn · $regionLabelEn',
    );
  }

  String get displayLabel => displayLabelFor(AppLanguage.english);
}

const List<VoiceLocaleOption> supportedVoiceLocales = [
  VoiceLocaleOption(
    code: 'de-DE',
    languageLabelKo: '독일어',
    regionLabelKo: '독일',
    languageLabelEn: 'German',
    regionLabelEn: 'Germany',
    previewHint: 'Guten Tag',
  ),
  VoiceLocaleOption(
    code: 'de-AT',
    languageLabelKo: '독일어',
    regionLabelKo: '오스트리아',
    languageLabelEn: 'German',
    regionLabelEn: 'Austria',
    previewHint: 'Servus',
  ),
  VoiceLocaleOption(
    code: 'de-CH',
    languageLabelKo: '독일어',
    regionLabelKo: '스위스',
    languageLabelEn: 'German',
    regionLabelEn: 'Switzerland',
    previewHint: 'Gruezi',
  ),
  VoiceLocaleOption(
    code: 'en-US',
    languageLabelKo: '영어',
    regionLabelKo: '미국',
    languageLabelEn: 'English',
    regionLabelEn: 'United States',
    previewHint: 'Hello there',
  ),
  VoiceLocaleOption(
    code: 'en-GB',
    languageLabelKo: '영어',
    regionLabelKo: '영국',
    languageLabelEn: 'English',
    regionLabelEn: 'United Kingdom',
    previewHint: 'Good afternoon',
  ),
  VoiceLocaleOption(
    code: 'ko-KR',
    languageLabelKo: '한국어',
    regionLabelKo: '대한민국',
    languageLabelEn: 'Korean',
    regionLabelEn: 'South Korea',
    previewHint: '안녕하세요',
  ),
  VoiceLocaleOption(
    code: 'fr-FR',
    languageLabelKo: '프랑스어',
    regionLabelKo: '프랑스',
    languageLabelEn: 'French',
    regionLabelEn: 'France',
    previewHint: 'Bonjour',
  ),
  VoiceLocaleOption(
    code: 'es-ES',
    languageLabelKo: '스페인어',
    regionLabelKo: '스페인',
    languageLabelEn: 'Spanish',
    regionLabelEn: 'Spain',
    previewHint: 'Hola',
  ),
  VoiceLocaleOption(
    code: 'ja-JP',
    languageLabelKo: '일본어',
    regionLabelKo: '일본',
    languageLabelEn: 'Japanese',
    regionLabelEn: 'Japan',
    previewHint: 'こんにちは',
  ),
];

VoiceLocaleOption voiceLocaleFromCode(String? code) {
  final normalized = normalizeVoiceLocale(code);

  for (final option in supportedVoiceLocales) {
    if (normalizeVoiceLocale(option.code).toLowerCase() ==
        normalized.toLowerCase()) {
      return option;
    }
  }

  return supportedVoiceLocales.first;
}

List<VoiceLocaleOption> voiceLocalesForLanguageCode(String? languageCode) {
  final studyLanguage = studyLanguageFromCode(languageCode);
  final matches = supportedVoiceLocales
      .where((option) => voiceLanguageCode(option.code) == studyLanguage.code)
      .toList(growable: false);

  return matches.isEmpty ? supportedVoiceLocales : matches;
}

String voiceLocaleForLanguageCode({
  required String? languageCode,
  required String? requestedLocale,
}) {
  final studyLanguage = studyLanguageFromCode(languageCode);
  final normalized = normalizeVoiceLocale(
    requestedLocale ?? studyLanguage.defaultTtsLocale,
  );

  if (voiceLanguageCode(normalized) == studyLanguage.code) {
    return voiceLocaleFromCode(normalized).code;
  }

  return voiceLocaleFromCode(studyLanguage.defaultTtsLocale).code;
}

String normalizeVoiceLocale(String? code) {
  final trimmed = code?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return defaultVoiceLocaleCode;
  }

  return trimmed.replaceAll('_', '-');
}

String voiceLanguageCode(String? code) {
  return normalizeVoiceLocale(code).split('-').first.toLowerCase();
}
