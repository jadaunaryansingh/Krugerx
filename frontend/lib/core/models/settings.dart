class SettingModel {
  final String theme;
  final String searchEngine;
  final String homepageUrl;
  final String language;
  final int fontSize;
  final bool privacyTrackingProtection;
  final String aiProvider;
  final String aiModel;

  SettingModel({
    this.theme = 'system',
    this.searchEngine = 'google',
    this.homepageUrl = 'https://google.com',
    this.language = 'en',
    this.fontSize = 14,
    this.privacyTrackingProtection = true,
    this.aiProvider = 'openai',
    this.aiModel = 'gpt-4o',
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      theme: json['theme'] as String? ?? 'system',
      searchEngine: json['search_engine'] as String? ?? 'google',
      homepageUrl: json['homepage_url'] as String? ?? 'https://google.com',
      language: json['language'] as String? ?? 'en',
      fontSize: json['font_size'] as int? ?? 14,
      privacyTrackingProtection: json['privacy_tracking_protection'] as bool? ?? true,
      aiProvider: json['ai_provider'] as String? ?? 'openai',
      aiModel: json['ai_model'] as String? ?? 'gpt-4o',
    );
  }

  SettingModel copyWith({
    String? theme,
    String? searchEngine,
    String? homepageUrl,
    String? language,
    int? fontSize,
    bool? privacyTrackingProtection,
    String? aiProvider,
    String? aiModel,
  }) {
    return SettingModel(
      theme: theme ?? this.theme,
      searchEngine: searchEngine ?? this.searchEngine,
      homepageUrl: homepageUrl ?? this.homepageUrl,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      privacyTrackingProtection: privacyTrackingProtection ?? this.privacyTrackingProtection,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
    );
  }
}
