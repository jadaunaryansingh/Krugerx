import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download.dart';
import 'auth_provider.dart';

final downloadsProvider = NotifierProvider<DownloadsNotifier, List<DownloadModel>>(DownloadsNotifier.new);

class DownloadsNotifier extends Notifier<List<DownloadModel>> {
  @override
  List<DownloadModel> build() => const [];

  Future<void> fetch() async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.get('/downloads');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((e) => DownloadModel.fromJson(e))
            .toList();
        state = list;
      }
    } catch (_) {}
  }
}
