import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void info(
    String scope,
    String message, {
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _log('INFO', scope, message, details: details);
  }

  static void warn(
    String scope,
    String message, {
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _log('WARN', scope, message, details: details);
  }

  static void error(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    _log(
      'ERROR',
      scope,
      message,
      details: details,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    String level,
    String scope,
    String message, {
    required Map<String, Object?> details,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final serializedDetails = details.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');

    final buffer = StringBuffer()
      ..write('[$timestamp][$level][$scope] ')
      ..write(message);

    if (serializedDetails.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(serializedDetails);
    }

    if (error != null) {
      buffer.write(' | error=$error');
    }

    debugPrint(buffer.toString());

    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
