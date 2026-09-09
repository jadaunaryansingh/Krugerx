import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage.dart';
import '../models/settings_models.dart';

class SettingsNotifier extends Notifier<LocalSettings> {
  @override
  LocalSettings build() {
    _init();
    return LocalSettings();
  }

  Future<void> _init() async {
    final settings = await Storage.db.localSettings.get(1);
    if (settings != null) {
      state = settings;
    }
  }

  Future<void> updateTheme(String theme) async {
    final updated = _cloneState()..theme = theme;
    await _save(updated);
  }

  Future<void> updateSearchEngine(String engine) async {
    final updated = _cloneState()..searchEngine = engine;
    await _save(updated);
  }

  Future<void> updatePrivacy(bool protection) async {
    final updated = _cloneState()..privacyTrackingProtection = protection;
    await _save(updated);
  }

  Future<void> updateHomepageUrl(String url) async {
    final updated = _cloneState()..homepageUrl = url;
    await _save(updated);
  }

  Future<void> updateLanguage(String lang) async {
    final updated = _cloneState()..language = lang;
    await _save(updated);
  }

  Future<void> updateFontSize(int size) async {
    final updated = _cloneState()..fontSize = size;
    await _save(updated);
  }

  Future<void> updateAiProvider(String provider) async {
    final updated = _cloneState()..aiProvider = provider;
    await _save(updated);
  }

  Future<void> updateAiModel(String model) async {
    final updated = _cloneState()..aiModel = model;
    await _save(updated);
  }

  Future<void> updatePersistSession(bool persist) async {
    final updated = _cloneState()..persistSession = persist;
    await _save(updated);
  }

  Future<void> updateBiometricUplink(bool val) async {
    final updated = _cloneState()..biometricUplink = val;
    await _save(updated);
  }

  Future<void> updateAesEncryption(bool val) async {
    final updated = _cloneState()..aesEncryption = val;
    await _save(updated);
  }

  Future<void> updateHardStrike(bool val) async {
    final updated = _cloneState()..hardStrike = val;
    await _save(updated);
  }

  Future<void> updateVpnTunnel(bool val) async {
    final updated = _cloneState()..vpnTunnel = val;
    await _save(updated);
  }

  Future<void> updateDnsOverHttps(bool val) async {
    final updated = _cloneState()..dnsOverHttps = val;
    await _save(updated);
  }

  LocalSettings _cloneState() {
    return LocalSettings()
      ..id = state.id
      ..theme = state.theme
      ..searchEngine = state.searchEngine
      ..homepageUrl = state.homepageUrl
      ..language = state.language
      ..fontSize = state.fontSize
      ..privacyTrackingProtection = state.privacyTrackingProtection
      ..aiProvider = state.aiProvider
      ..aiModel = state.aiModel
      ..synced = false
      ..persistSession = state.persistSession
      ..biometricUplink = state.biometricUplink
      ..aesEncryption = state.aesEncryption
      ..hardStrike = state.hardStrike
      ..vpnTunnel = state.vpnTunnel
      ..dnsOverHttps = state.dnsOverHttps;
  }

  Future<void> _save(LocalSettings settings) async {
    await Storage.db.writeTxn(() async {
      await Storage.db.localSettings.put(settings);
    });
    state = settings;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, LocalSettings>(SettingsNotifier.new);
