class TabModel {
  final String id;
  final String title;
  final String url;
  final String? faviconUrl;
  final bool isIncognito;
  final bool isDesktopMode;
  final bool isNightMode;
  final double zoomLevel;
  final bool isPinned;
  final bool isMuted;
  final double loadingProgress;
  // Session/ordering fields
  final String sessionId;
  final bool active;
  final bool pinned;
  final String? tabGroupId;
  final double zoomScale;
  final bool isReaderMode;
  final int position;

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
    this.sessionId = 'local',
    this.active = false,
    this.pinned = false,
    this.tabGroupId,
    this.zoomScale = 1.0,
    this.isReaderMode = false,
    this.position = 0,
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
    String? sessionId,
    bool? active,
    bool? pinned,
    String? tabGroupId,
    double? zoomScale,
    bool? isReaderMode,
    int? position,
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
        sessionId: sessionId ?? this.sessionId,
        active: active ?? this.active,
        pinned: pinned ?? this.pinned,
        tabGroupId: tabGroupId ?? this.tabGroupId,
        zoomScale: zoomScale ?? this.zoomScale,
        isReaderMode: isReaderMode ?? this.isReaderMode,
        position: position ?? this.position,
      );
}
