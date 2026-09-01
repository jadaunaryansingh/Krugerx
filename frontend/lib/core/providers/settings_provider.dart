import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import 'auth_provider.dart';
import '../storage.dart';
import '../../features/settings/models/settings_models.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingModel>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingModel> {
  @override
  SettingModel build() {
    return _loadLocal() ?? SettingModel(); 
  }

  SettingModel? _loadLocal() {
    final local = Storage.db.localSettings.getSync(1);
    if (local != null) {
      return SettingModel(
        theme: local.theme,
        searchEngine: local.searchEngine,
        homepageUrl: local.homepageUrl,
        language: local.language,
        fontSize: local.fontSize,
        privacyTrackingProtection: local.privacyTrackingProtection,
        aiProvider: local.aiProvider,
        aiModel: local.aiModel,
      );
    }
    return null;
  }

  Future<void> fetch() async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.get('/settings');
      if (res.data['success'] == true) {
        final serverSettings = SettingModel.fromJson(res.data['data']);
        await updateSettings(serverSettings, syncToServer: false);
      }
    } catch (_) {}
  }

  Future<void> updateSettings(SettingModel newSettings, {bool syncToServer = true}) async {
    state = newSettings; // Optimistic update

    // Save locally to Isar
    await Storage.db.writeTxn(() async {
      final local = await Storage.db.localSettings.get(1) ?? LocalSettings();
      local.theme = newSettings.theme;
      local.searchEngine = newSettings.searchEngine;
      local.homepageUrl = newSettings.homepageUrl;
      local.language = newSettings.language;
      local.fontSize = newSettings.fontSize;
      local.privacyTrackingProtection = newSettings.privacyTrackingProtection;
      local.aiProvider = newSettings.aiProvider;
      local.aiModel = newSettings.aiModel;
      local.synced = !syncToServer; // If we need to sync, mark it false
      await Storage.db.localSettings.put(local);
    });

    if (syncToServer) {
      final api = ref.read(apiClientProvider);
      try {
        await api.dio.put('/settings', data: {
          'theme': newSettings.theme,
          'search_engine': newSettings.searchEngine,
          'homepage_url': newSettings.homepageUrl,
          'language': newSettings.language,
          'font_size': newSettings.fontSize,
          'privacy_tracking_protection': newSettings.privacyTrackingProtection,
          'ai_provider': newSettings.aiProvider,
          'ai_model': newSettings.aiModel,
        });
        
        await Storage.db.writeTxn(() async {
          final local = await Storage.db.localSettings.get(1);
          if (local != null) {
            local.synced = true;
            await Storage.db.localSettings.put(local);
          }
        });
      } catch (_) {}
    }
  }
}
