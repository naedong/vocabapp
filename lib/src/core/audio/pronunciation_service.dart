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

class PronunciationPlaybackException implements Exception {
  const PronunciationPlaybackException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FlutterTtsPronunciationService implements PronunciationService {
  FlutterTtsPronunciationService({FlutterTts? tts})
    : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  final Map<String, String> _resolvedLocales = <String, String>{};
  Set<String>? _availableLocales;
  bool _isConfigured = false;
  String? _activeLocale;
  String? _lastPlaybackError;

  Future<void> _configureIfNeeded() async {
    if (_isConfigured) {
      return;
    }

    _tts.setErrorHandler((message) {
      _lastPlaybackError = '$message';
    });
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
    _lastPlaybackError = null;
    await _tts.stop();
    final result = await _tts.speak(trimmed, focus: true);
    final playbackError = _lastPlaybackError;
    if (_isPlatformFailure(result) ||
        (playbackError != null && playbackError.trim().isNotEmpty)) {
      throw PronunciationPlaybackException(
        playbackError?.trim().isNotEmpty == true
            ? playbackError!.trim()
            : 'Text-to-speech playback could not start.',
      );
    }
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
    final candidates = await _resolveLocaleCandidates(requestedLocale);
    Object? lastError;

    for (final locale in candidates) {
      if (_activeLocale == locale) {
        return;
      }

      try {
        final isAvailable = await _isLanguageAvailable(locale);
        if (isAvailable == false) {
          continue;
        }

        final result = await _tts.setLanguage(locale);
        if (_isPlatformFailure(result)) {
          continue;
        }

        _activeLocale = locale;
        return;
      } catch (error) {
        lastError = error;
      }
    }

    throw PronunciationPlaybackException(
      'No usable TTS voice was found for ${candidates.first}.'
      '${lastError == null ? '' : ' $lastError'}',
    );
  }

  Future<List<String>> _resolveLocaleCandidates(String? requestedLocale) async {
    final desired = normalizeVoiceLocale(requestedLocale);
    final cached = _resolvedLocales[desired];
    if (cached != null) {
      return [cached, defaultVoiceLocaleCode]
          .where((locale) => locale.trim().isNotEmpty)
          .toSet()
          .toList(growable: false);
    }

    final available = await _loadAvailableLocales();
    final resolved = _pickBestLocale(desired, available);
    _resolvedLocales[desired] = resolved;
    final candidates = <String>[
      resolved,
      desired,
      if (voiceLanguageCode(desired) == 'de') ...[
        defaultVoiceLocaleCode,
        'de-AT',
        'de-CH',
      ],
      if (voiceLanguageCode(desired) != 'de') defaultVoiceLocaleCode,
    ];

    return candidates
        .where((locale) => locale.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
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

  Future<bool?> _isLanguageAvailable(String locale) async {
    try {
      final result = await _tts.isLanguageAvailable(locale);
      if (result is bool) {
        return result;
      }
      if (result is num) {
        return result >= 0;
      }
      final normalized = '$result'.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  bool _isPlatformFailure(Object? result) {
    if (result == null) {
      return false;
    }
    if (result is bool) {
      return !result;
    }
    if (result is num) {
      return result <= 0;
    }
    final normalized = '$result'.trim().toLowerCase();
    return normalized == 'false' ||
        normalized == 'error' ||
        normalized == 'failed' ||
        normalized == 'failure';
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
