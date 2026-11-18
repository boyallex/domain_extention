abstract interface class ILogService {
  void debug(String message, {String tag = 'app', Object? data});

  void info(String message, {String tag = 'app', Object? data});

  void warn(String message, {String tag = 'app', Object? data});

  void error(
    String message, {
    String tag = 'app',
    Object? error,
    StackTrace? stackTrace,
  });
}
