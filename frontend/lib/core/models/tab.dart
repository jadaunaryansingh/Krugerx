class TabModel {
  final String id;
  final String sessionId;
  final String? tabGroupId;
  final String? title;
  final String url;
  final String? faviconUrl;
  final bool pinned;
  final bool active;
  final int position;
  final bool isMuted;
  final bool isReaderMode;
  final double zoomScale;

  TabModel({
    required this.id,
    required this.sessionId,
    this.tabGroupId,
    this.title,
    required this.url,
    this.faviconUrl,
    this.pinned = false,
    this.active = false,
    this.position = 0,
    this.isMuted = false,
    this.isReaderMode = false,
    this.zoomScale = 1.0,
  });

  factory TabModel.fromJson(Map<String, dynamic> json) {
    return TabModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      tabGroupId: json['tab_group_id'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String,
      faviconUrl: json['favicon_url'] as String?,
      pinned: json['pinned'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      position: json['position'] as int? ?? 0,
      isMuted: json['isMuted'] as bool? ?? false,
      isReaderMode: json['isReaderMode'] as bool? ?? false,
      zoomScale: (json['zoomScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  TabModel copyWith({
    String? id,
    String? sessionId,
    String? tabGroupId,
    String? title,
    String? url,
    String? faviconUrl,
    bool? pinned,
    bool? active,
    int? position,
    bool? isMuted,
    bool? isReaderMode,
    double? zoomScale,
  }) {
    return TabModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      tabGroupId: tabGroupId ?? this.tabGroupId,
      title: title ?? this.title,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      pinned: pinned ?? this.pinned,
      active: active ?? this.active,
      position: position ?? this.position,
      isMuted: isMuted ?? this.isMuted,
      isReaderMode: isReaderMode ?? this.isReaderMode,
      zoomScale: zoomScale ?? this.zoomScale,
    );
  }
}

class TabGroupModel {
  final String id;
  final String? workspaceId;
  final String title;
  final String? color;
  final bool isCollapsed;
  final List<String> tabIds;

  TabGroupModel({
    required this.id,
    this.workspaceId,
    required this.title,
    this.color,
    this.isCollapsed = false,
    this.tabIds = const [],
  });

  factory TabGroupModel.fromJson(Map<String, dynamic> json) {
    return TabGroupModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String?,
      title: json['title'] as String,
      color: json['color'] as String?,
      isCollapsed: json['is_collapsed'] as bool? ?? false,
      tabIds: (json['tabIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
