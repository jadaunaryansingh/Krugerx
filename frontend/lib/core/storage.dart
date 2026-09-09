import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../features/auth/models/auth_models.dart';
import '../features/bookmarks/models/bookmark_models.dart';
import '../features/history/models/history_models.dart';
import '../features/downloads/models/download_models.dart';
import '../features/settings/models/settings_models.dart';
import '../features/ai/models/ai_models.dart';
import '../features/browser/models/session_models.dart';

class Storage {
  Storage._();

  static late final Isar db;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      db = await Isar.open(
        [
          AuthSessionSchema,
          LocalBookmarkSchema,
          LocalFolderSchema,
          LocalHistorySchema,
          LocalDownloadSchema,
          LocalSettingsSchema,
          LocalChatSessionSchema,
          LocalChatMessageSchema,
          LocalSessionTabSchema,
        ],
        directory: dir.path,
      );
    } catch (e) {
      // If schema mismatch or corruption occurs, Isar throws.
      // To prevent bricking the app, we clean up the directory and try again.
      final isarFiles = dir.listSync().where((f) => f.path.endsWith('.isar') || f.path.endsWith('.isar.lock'));
      for (var f in isarFiles) {
        try { f.deleteSync(); } catch (e) { debugPrint('[Storage] deleteSync error: $e'); }
      }
      db = await Isar.open(
        [
          AuthSessionSchema,
          LocalBookmarkSchema,
          LocalFolderSchema,
          LocalHistorySchema,
          LocalDownloadSchema,
          LocalSettingsSchema,
          LocalChatSessionSchema,
          LocalChatMessageSchema,
          LocalSessionTabSchema,
        ],
        directory: dir.path,
      );
    }

    // Initialize default settings if not exists
    final existingSettings = await db.localSettings.get(1);
    if (existingSettings == null) {
      await db.writeTxn(() async {
        await db.localSettings.put(LocalSettings());
      });
    }
  }
}
