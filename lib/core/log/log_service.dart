import 'dart:developer' as developer;

import 'package:domain_extention/core/log/i_log_service.dart';

class LogService implements ILogService {
  const LogService();

  @override
  void debug(String message, {String tag = 'app', Object? data}) {
    _write(message, tag: tag, data: data, level: 500);
  }

  @override
  void info(String message, {String tag = 'app', Object? data}) {
    _write(message, tag: tag, data: data, level: 800);
  }

  @override
  void warn(String message, {String tag = 'app', Object? data}) {
    _write(message, tag: tag, data: data, level: 900);
  }

  @override
  void error(
    String message, {
    String tag = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _write(
      message,
      tag: tag,
      data: error,
      level: 1000,
      stackTrace: stackTrace,
    );
  }

  void _write(
    String message, {
    required String tag,
    required int level,
    Object? data,
    StackTrace? stackTrace,
  }) {
    final line = data == null ? message : '$message | $data';
    developer.log(
      '[$tag] $line',
      name: tag,
      level: level,
      error: level >= 1000 ? data : null,
      stackTrace: stackTrace,
    );
  }
}
