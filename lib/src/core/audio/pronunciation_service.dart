import 'package:flutter_tts/flutter_tts.dart';

import 'voice_locale.dart';

abstract class PronunciationService {
  Future<void> speak(String text, {String? locale});
  Future<void> stop();
  Future<void> dispose();

  Future<void> speakGerman(String text) {
    return speak(text, locale: defaultVoiceLocaleCode);
  }
}

class FlutterTtsPronunciationService implements PronunciationService {
  FlutterTtsPronunciationService({FlutterTts? tts})
    : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  final Map<String, String> _resolvedLocales = <String, String>{};
  Set<String>? _availableLocales;
  bool _isConfigured = false;
  String? _activeLocale;

  Future<void> _configureIfNeeded() async {
    if (_isConfigured) {
      return;
    }

    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _isConfigured = true;
  }

  @override
  Future<void> speak(String text, {String? locale}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _configureIfNeeded();
    await _setLocale(locale);
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  @override
  Future<void> speakGerman(String text) {
    return speak(text, locale: defaultVoiceLocaleCode);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<void> dispose() => _tts.stop();

  Future<void> _setLocale(String? requestedLocale) async {
    final resolved = await _resolveLocale(requestedLocale);

    if (_activeLocale == resolved) {
      return;
    }

    try {
      await _tts.setLanguage(resolved);
      _activeLocale = resolved;
    } catch (_) {
      if (_activeLocale == defaultVoiceLocaleCode) {
        rethrow;
      }

      await _tts.setLanguage(defaultVoiceLocaleCode);
      _activeLocale = defaultVoiceLocaleCode;
    }
  }

  Future<String> _resolveLocale(String? requestedLocale) async {
    final desired = normalizeVoiceLocale(requestedLocale);
    final cached = _resolvedLocales[desired];
    if (cached != null) {
      return cached;
    }

    final available = await _loadAvailableLocales();
    final resolved = _pickBestLocale(desired, available);
    _resolvedLocales[desired] = resolved;
    return resolved;
  }

  Future<Set<String>> _loadAvailableLocales() async {
    final cached = _availableLocales;
    if (cached != null) {
      return cached;
    }

    final loaded = <String>{};

    try {
      final languages = await _tts.getLanguages;
      if (languages is List) {
        for (final language in languages) {
          final value = '$language'.trim();
          if (value.isNotEmpty) {
            loaded.add(normalizeVoiceLocale(value));
          }
        }
      }
    } catch (_) {
      return _availableLocales = <String>{};
    }

    _availableLocales = loaded;
    return loaded;
  }

  String _pickBestLocale(String desired, Set<String> available) {
    if (available.isEmpty) {
      return desired;
    }

    final lowerLookup = <String, String>{
      for (final locale in available) locale.toLowerCase(): locale,
    };

    final exact = lowerLookup[desired.toLowerCase()];
    if (exact != null) {
      return exact;
    }

    final desiredLanguage = voiceLanguageCode(desired);
    final sameLanguage = available.where((locale) {
      return voiceLanguageCode(locale) == desiredLanguage;
    }).toList()..sort();

    if (sameLanguage.isNotEmpty) {
      return sameLanguage.first;
    }

    final fallback = lowerLookup[defaultVoiceLocaleCode.toLowerCase()];
    return fallback ?? available.first;
  }
}

class SilentPronunciationService implements PronunciationService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> speak(String text, {String? locale}) async {}

  @override
  Future<void> speakGerman(String text) async {}

  @override
  Future<void> stop() async {}
}
