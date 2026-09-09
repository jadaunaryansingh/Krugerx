import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krugerx/core/storage.dart';
import 'package:krugerx/core/api_client.dart';
import 'package:krugerx/features/auth/models/auth_models.dart';
import 'package:krugerx/features/bookmarks/models/bookmark_models.dart';
import 'package:krugerx/features/history/models/history_models.dart';
import 'package:krugerx/features/downloads/models/download_models.dart';
import 'package:krugerx/features/settings/models/settings_models.dart';
import 'package:krugerx/features/ai/models/ai_models.dart';
import 'package:krugerx/features/browser/models/session_models.dart';

Future<void> setupTestEnvironment() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mock SharedPreferences
  SharedPreferences.setMockInitialValues({});
  
  // Initialize Isar in temp directory
  try {
    await Isar.initializeIsarCore(download: true);
  } catch (e) {
    // Already initialized or fails (might not fail if already initialized)
  }
  
  final tempDir = Directory.systemTemp.createTempSync('krugerx_test');
  
  // Clean up any existing instances
  if (Isar.instanceNames.isNotEmpty) {
    for (final name in Isar.instanceNames) {
      final isar = Isar.getInstance(name);
      if (isar != null && isar.isOpen) {
        await isar.close(deleteFromDisk: true);
      }
    }
  }

  try {
    Storage.db = await Isar.open(
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
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Initialize default settings if not exists
    final existingSettings = await Storage.db.localSettings.get(1);
    if (existingSettings == null) {
      await Storage.db.writeTxn(() async {
        await Storage.db.localSettings.put(LocalSettings());
      });
    }
  } catch (e) {
    debugPrint('Could not initialize Isar in test_helper: $e');
  }

  ApiClient.init();
}
