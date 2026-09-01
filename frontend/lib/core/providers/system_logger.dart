import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LogLevel { info, warning, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}

class SystemLoggerNotifier extends Notifier<List<LogEntry>> {
  static const int _maxEntries = 50;

  @override
  List<LogEntry> build() {
    return [
      LogEntry(
        timestamp: DateTime.now().toUtc(),
        level: LogLevel.info,
        message: "ENFIELD_OS KERNEL v4.1.9-rt34 BOOT SEQ INITIATED",
      ),
    ];
  }

  void addLog(LogLevel level, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now().toUtc(),
      level: level,
      message: message,
    );

    final updated = List<LogEntry>.from(state)..add(entry);
    if (updated.length > _maxEntries) {
      updated.removeRange(0, updated.length - _maxEntries);
    }
    state = updated;
  }
}

final systemLoggerProvider = NotifierProvider<SystemLoggerNotifier, List<LogEntry>>(
  SystemLoggerNotifier.new,
);
