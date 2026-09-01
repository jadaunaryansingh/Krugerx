import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/storage.dart';
import '../models/download_models.dart';

class DownloadsNotifier extends Notifier<List<LocalDownload>> {
  @override
  List<LocalDownload> build() {
    _watchData();
    return const [];
  }

  void _watchData() {
    _fetch();
    Storage.db.localDownloads.watchLazy().listen((_) => _fetch());
  }

  Future<void> _fetch() async {
    final downloads = await Storage.db.localDownloads.where().sortByCreatedAtDesc().findAll();
    state = downloads;
  }

  // Simulated for now — in a real app, uses flutter_downloader or Dio for actual background download.
  Future<void> startDownload(String url, String filename) async {
    final download = LocalDownload()
      ..url = url
      ..filename = filename
      ..status = 'downloading'
      ..progress = 0.1
      ..createdAt = DateTime.now();

    await Storage.db.writeTxn(() async {
      await Storage.db.localDownloads.put(download);
    });

    // Simulate progress
    Future.delayed(const Duration(seconds: 2), () async {
      await Storage.db.writeTxn(() async {
        final d = await Storage.db.localDownloads.get(download.id);
        if (d != null) {
          d.status = 'completed';
          d.progress = 1.0;
          d.completedAt = DateTime.now();
          await Storage.db.localDownloads.put(d);
        }
      });
    });
  }

  Future<void> clearCompleted() async {
    await Storage.db.writeTxn(() async {
      await Storage.db.localDownloads.filter().statusEqualTo('completed').deleteAll();
    });
  }
}

final downloadsProvider = NotifierProvider<DownloadsNotifier, List<LocalDownload>>(DownloadsNotifier.new);
