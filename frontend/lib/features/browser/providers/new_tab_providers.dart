import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeedDialItem {
  final String label;
  final String url;
  final String iconUrl;

  const SpeedDialItem({
    required this.label,
    required this.url,
    required this.iconUrl,
  });
}

final speedDialProvider = Provider<List<SpeedDialItem>>((ref) {
  return const [
    SpeedDialItem(
      label: 'Google',
      url: 'https://google.com',
      iconUrl: 'https://www.google.com/favicon.ico',
    ),
    SpeedDialItem(
      label: 'YouTube',
      url: 'https://youtube.com',
      iconUrl: 'https://www.youtube.com/favicon.ico',
    ),
    SpeedDialItem(
      label: 'GitHub',
      url: 'https://github.com',
      iconUrl: 'https://github.com/favicon.ico',
    ),
    SpeedDialItem(
      label: 'Reddit',
      url: 'https://reddit.com',
      iconUrl: 'https://www.redditstatic.com/favicon.ico',
    ),
    SpeedDialItem(
      label: 'X (Twitter)',
      url: 'https://x.com',
      iconUrl: 'https://abs.twimg.com/favicons/twitter.2.ico',
    ),
  ];
});

class BrowserStats {
  final int trackersBlocked;
  final int bandwidthSavedMb;
  final int timeSavedMinutes;

  const BrowserStats({
    required this.trackersBlocked,
    required this.bandwidthSavedMb,
    required this.timeSavedMinutes,
  });
}

class BrowserStatsNotifier extends Notifier<BrowserStats> {
  @override
  BrowserStats build() {
    _loadStats();
    return const BrowserStats(trackersBlocked: 0, bandwidthSavedMb: 0, timeSavedMinutes: 0);
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    state = BrowserStats(
      trackersBlocked: prefs.getInt('trackersBlocked') ?? 0,
      bandwidthSavedMb: prefs.getInt('bandwidthSavedMb') ?? 0,
      timeSavedMinutes: prefs.getInt('timeSavedMinutes') ?? 0,
    );
  }

  Future<void> incrementStats({int trackers = 0, int bandwidth = 0, int time = 0}) async {
    final newTrackers = state.trackersBlocked + trackers;
    final newBandwidth = state.bandwidthSavedMb + bandwidth;
    final newTime = state.timeSavedMinutes + time;

    state = BrowserStats(
      trackersBlocked: newTrackers,
      bandwidthSavedMb: newBandwidth,
      timeSavedMinutes: newTime,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trackersBlocked', newTrackers);
    await prefs.setInt('bandwidthSavedMb', newBandwidth);
    await prefs.setInt('timeSavedMinutes', newTime);
  }
}

final browserStatsProvider = NotifierProvider<BrowserStatsNotifier, BrowserStats>(() {
  return BrowserStatsNotifier();
});
