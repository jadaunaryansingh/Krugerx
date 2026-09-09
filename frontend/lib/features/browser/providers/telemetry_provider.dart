import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/system_logger.dart';
import '../../../core/constants.dart';

class TelemetryState {
  final String uptime;
  final String systemTime;
  final String memory;
  final double cpuCycles;
  final double latency;
  final double packetLoss;
  final double jitter;
  final double freqScan;

  TelemetryState({
    required this.uptime,
    required this.systemTime,
    required this.memory,
    required this.cpuCycles,
    required this.latency,
    required this.packetLoss,
    required this.jitter,
    required this.freqScan,
  });

  TelemetryState copyWith({
    String? uptime,
    String? systemTime,
    String? memory,
    double? cpuCycles,
    double? latency,
    double? packetLoss,
    double? jitter,
    double? freqScan,
  }) {
    return TelemetryState(
      uptime: uptime ?? this.uptime,
      systemTime: systemTime ?? this.systemTime,
      memory: memory ?? this.memory,
      cpuCycles: cpuCycles ?? this.cpuCycles,
      latency: latency ?? this.latency,
      packetLoss: packetLoss ?? this.packetLoss,
      jitter: jitter ?? this.jitter,
      freqScan: freqScan ?? this.freqScan,
    );
  }
}

class TelemetryNotifier extends Notifier<TelemetryState> {
  Timer? _timer;
  Timer? _latencyTimer;
  final _random = Random();
  late final DateTime _appStartTime;
  
  // Buffers for Jitter calc
  final List<double> _latencyBuffer = [];
  final int _maxBufferSize = 10;

  // Buffer for Packet Loss calc (30 pings rolling window)
  final List<bool> _packetLossBuffer = [];
  final int _maxLossBufferSize = 30;


  @override
  TelemetryState build() {
    _appStartTime = DateTime.now();
    
    // Initial state
    final state = TelemetryState(
      uptime: '00:00:00:00',
      systemTime: _formatTime(DateTime.now()),
      memory: _getMemory(),
      cpuCycles: 1.24,
      latency: 0.0,
      packetLoss: 0.0,
      jitter: 0.0,
      freqScan: 144.2,
    );

    // Ensure we run the timer on the next event loop to not block build
    Future.microtask(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      _latencyTimer = Timer.periodic(const Duration(seconds: 2), (_) => _measureLatency());
    });

    // Cleanup timer if provider is destroyed (if autoDispose was used, but it's not)
    ref.onDispose(() {
      _timer?.cancel();
      _latencyTimer?.cancel();
    });

    return state;
  }

  void _tick() {
    final now = DateTime.now();
    
    // UPTIME
    final diff = now.difference(_appStartTime);
    final days = diff.inDays.toString().padLeft(2, '0');
    final hours = (diff.inHours % 24).toString().padLeft(2, '0');
    final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');
    
    // MEMORY (Real)
    final memoryStr = _getMemory();

    // CPU CYCLES (Simulated bounded random walk: 0.8 - 3.5 GHz)
    double newCpu = state.cpuCycles + (_random.nextDouble() * 0.2 - 0.1);
    if (_random.nextDouble() < 0.05) newCpu += 1.0; // Anomaly spike
    newCpu = newCpu.clamp(0.8, 3.5);

    // FREQUENCY SCAN (Derived from latency & packet loss)
    // Base 144.2, drops if latency/loss is bad.
    double newFreq = 144.2 - (state.latency / 100.0) - (state.packetLoss * 0.5);
    newFreq = newFreq.clamp(130.0, 145.0);

    state = state.copyWith(
      uptime: '$days:$hours:$mins:$secs',
      systemTime: _formatTime(now),
      memory: memoryStr,
      cpuCycles: newCpu,
      freqScan: newFreq,
    );
  }

  Future<void> _measureLatency() async {
    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse(AppConstants.apiBaseUrl);
      final request = await HttpClient().headUrl(uri).timeout(const Duration(seconds: 2));
      await (await request.close()).drain<void>();
      stopwatch.stop();
      _updateLatencyState(stopwatch.elapsedMilliseconds.toDouble(), true);
    } catch (e) {
      _updateLatencyState(500.0 + _random.nextDouble() * 500.0, false);
    }
  }

  void _updateLatencyState(double ms, bool success) {
    _latencyBuffer.add(ms);
    if (_latencyBuffer.length > _maxBufferSize) {
      _latencyBuffer.removeAt(0);
    }

    _packetLossBuffer.add(success);
    if (_packetLossBuffer.length > _maxLossBufferSize) {
      _packetLossBuffer.removeAt(0);
    }

    double jitter = 0.0;
    if (_latencyBuffer.length > 1) {
      // Variance/StdDev for Jitter
      double sum = _latencyBuffer.reduce((a, b) => a + b);
      double mean = sum / _latencyBuffer.length;
      double sqSum = 0;
      for (var val in _latencyBuffer) {
        sqSum += pow(val - mean, 2);
      }
      double variance = sqSum / (_latencyBuffer.length - 1);
      jitter = sqrt(variance);
    }

    int failures = _packetLossBuffer.where((s) => !s).length;
    double packetLoss = _packetLossBuffer.isEmpty ? 0.0 : (failures / _packetLossBuffer.length) * 100.0;

    // Detect anomaly spike (e.g., > 10% packet loss)
    if (packetLoss > 10.0 && packetLoss > state.packetLoss) {
      ref.read(systemLoggerProvider.notifier).addLog(
        LogLevel.warning, 
        'NETWORK ANOMALY DETECTED: HTTP-heartbeat packet loss exceeded threshold ($packetLoss%)'
      );
    }

    state = state.copyWith(
      latency: ms,
      jitter: jitter,
      packetLoss: packetLoss,
    );
  }

  String _getMemory() {
    try {
      final bytes = ProcessInfo.currentRss;
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

final telemetryProvider = NotifierProvider<TelemetryNotifier, TelemetryState>(TelemetryNotifier.new);
