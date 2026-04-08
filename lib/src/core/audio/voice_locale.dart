const String defaultVoiceLocaleCode = 'de-DE';

class VoiceLocaleOption {
  const VoiceLocaleOption({
    required this.code,
    required this.languageLabel,
    required this.regionLabel,
    required this.previewHint,
  });

  final String code;
  final String languageLabel;
  final String regionLabel;
  final String previewHint;

  String get displayLabel => '$languageLabel · $regionLabel';
}

const List<VoiceLocaleOption> supportedVoiceLocales = [
  VoiceLocaleOption(
    code: 'de-DE',
    languageLabel: '독일어',
    regionLabel: '독일',
    previewHint: 'Guten Tag',
  ),
  VoiceLocaleOption(
    code: 'de-AT',
    languageLabel: '독일어',
    regionLabel: '오스트리아',
    previewHint: 'Servus',
  ),
  VoiceLocaleOption(
    code: 'de-CH',
    languageLabel: '독일어',
    regionLabel: '스위스',
    previewHint: 'Gruezi',
  ),
  VoiceLocaleOption(
    code: 'en-US',
    languageLabel: '영어',
    regionLabel: '미국',
    previewHint: 'Hello there',
  ),
  VoiceLocaleOption(
    code: 'en-GB',
    languageLabel: '영어',
    regionLabel: '영국',
    previewHint: 'Good afternoon',
  ),
  VoiceLocaleOption(
    code: 'ko-KR',
    languageLabel: '한국어',
    regionLabel: '대한민국',
    previewHint: '안녕하세요',
  ),
  VoiceLocaleOption(
    code: 'fr-FR',
    languageLabel: '프랑스어',
    regionLabel: '프랑스',
    previewHint: 'Bonjour',
  ),
  VoiceLocaleOption(
    code: 'es-ES',
    languageLabel: '스페인어',
    regionLabel: '스페인',
    previewHint: 'Hola',
  ),
  VoiceLocaleOption(
    code: 'ja-JP',
    languageLabel: '일본어',
    regionLabel: '일본',
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
