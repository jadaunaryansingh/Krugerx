import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/api_client.dart';
import '../../../core/storage.dart';
import '../features/auth/models/auth_models.dart';
import '../features/bookmarks/models/bookmark_models.dart';

class SyncService {
  SyncService._();

  static Future<void> syncAll(WidgetRef ref) async {
    final session = await Storage.db.authSessions.where().findFirst();
    // Only sync if user is logged in
    if (session == null || session.accessToken == null) return;

    try {
      // 1. Push Local Changes
      await _pushBookmarks();
      await _pushHistory();

      // 2. Pull Remote Changes
      await _pullChanges();

    } catch (e) {
      // Background sync failed, ignore for now
    }
  }

  static Future<void> _pushBookmarks() async {
    final unsynced = await Storage.db.localBookmarks.filter().syncedEqualTo(false).findAll();
    if (unsynced.isEmpty) return;

    for (final bm in unsynced) {
      final response = await ApiClient.client.post('/sync/push', data: {
        'entity_type': 'bookmark',
        'entity_id': bm.remoteId ?? '', // Requires a UUID generator in real app
        'action': 'create',
        'payload': {
          'title': bm.title,
          'url': bm.url,
          'folder_id': bm.folderId,
        }
      });
      
      if (response.statusCode == 200) {
        await Storage.db.writeTxn(() async {
          bm.synced = true;
          await Storage.db.localBookmarks.put(bm);
        });
      }
    }
  }

  static Future<void> _pushHistory() async {
     // Similar implementation for pushing unsynced history records
  }

  static Future<void> _pullChanges() async {
    // Basic polling mechanism to pull queue items from backend
    final response = await ApiClient.client.get('/sync/pull');
    if (response.statusCode == 200 && response.data['success']) {
      final queueItems = response.data['data']['queue_items'] as List;
      for (final _ in queueItems) {
        // apply payload to local Isar DB
      }
    }
  }
}
