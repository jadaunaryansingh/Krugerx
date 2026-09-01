import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history.dart';
import 'auth_provider.dart';

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryModel>>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<List<HistoryModel>> {
  @override
  List<HistoryModel> build() => const [];

  Future<void> fetch() async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.get('/history');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((e) => HistoryModel.fromJson(e))
            .toList();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> addHistory(String url, String title) async {
    final api = ref.read(apiClientProvider);
    try {
      await api.dio.post('/history', data: {
        'url': url,
        'title': title,
      });
      // Do not block or force re-fetch immediately for performance
    } catch (_) {}
  }
}
