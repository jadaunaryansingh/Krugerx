import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

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

    // Initialize default settings if not exists
    final existingSettings = await db.localSettings.get(1);
    if (existingSettings == null) {
      await db.writeTxn(() async {
        await db.localSettings.put(LocalSettings());
      });
    }
  }
}
