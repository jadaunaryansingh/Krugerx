class TabModel {
  final String id;
  final String title;
  final String url;
  final String? faviconUrl;
  final bool isIncognito;
  final bool isDesktopMode;
  final bool isNightMode;
  final double zoomLevel;
  
  // Phase A: Tab Management Foundation
  final bool isPinned;
  final bool isMuted;
  final double loadingProgress;

  const TabModel({
    required this.id,
    this.title = 'New Tab',
    this.url = '',
    this.faviconUrl,
    this.isIncognito = false,
    this.isDesktopMode = false,
    this.isNightMode = false,
    this.zoomLevel = 1.0,
    this.isPinned = false,
    this.isMuted = false,
    this.loadingProgress = 0.0,
  });

  TabModel copyWith({
    String? title,
    String? url,
    String? faviconUrl,
    bool? isIncognito,
    bool? isDesktopMode,
    bool? isNightMode,
    double? zoomLevel,
    bool? isPinned,
    bool? isMuted,
    double? loadingProgress,
  }) =>
      TabModel(
        id: id,
        title: title ?? this.title,
        url: url ?? this.url,
        faviconUrl: faviconUrl ?? this.faviconUrl,
        isIncognito: isIncognito ?? this.isIncognito,
        isDesktopMode: isDesktopMode ?? this.isDesktopMode,
        isNightMode: isNightMode ?? this.isNightMode,
        zoomLevel: zoomLevel ?? this.zoomLevel,
        isPinned: isPinned ?? this.isPinned,
        isMuted: isMuted ?? this.isMuted,
        loadingProgress: loadingProgress ?? this.loadingProgress,
      );
}
