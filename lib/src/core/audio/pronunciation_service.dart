import 'package:flutter_tts/flutter_tts.dart';

abstract class PronunciationService {
  Future<void> speakGerman(String text);
  Future<void> stop();
  Future<void> dispose();
}

class FlutterTtsPronunciationService implements PronunciationService {
  FlutterTtsPronunciationService({FlutterTts? tts})
    : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _isConfigured = false;

  Future<void> _configureIfNeeded() async {
    if (_isConfigured) {
      return;
    }

    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _isConfigured = true;
  }

  @override
  Future<void> speakGerman(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _configureIfNeeded();
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<void> dispose() => _tts.stop();
}

class SilentPronunciationService implements PronunciationService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> speakGerman(String text) async {}

  @override
  Future<void> stop() async {}
}
