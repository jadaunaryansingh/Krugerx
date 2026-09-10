import 'package:isar_community/isar.dart';

part 'settings_models.g.dart';

@collection
class LocalSettings {
  Id id = 1; // Singleton

  String theme = 'system';
  String searchEngine = 'google';
  String homepageUrl = 'https://google.com';
  String language = 'en';
  int fontSize = 14;
  bool privacyTrackingProtection = true;
  String aiProvider = 'openai';
  String aiModel = 'gpt-4o';
  bool synced = false;
  bool persistSession = true;
  // Security settings
  bool biometricUplink = true;
  bool aesEncryption = true;
  bool hardStrike = false;
  // Network settings
  bool vpnTunnel = true;
  bool dnsOverHttps = true;
  bool historySuggestions = true;
}
