class BookmarkModel {
  final String id;
  final String title;
  final String url;
  final String? folderId;
  final int position;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.url,
    this.folderId,
    this.position = 0,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      folderId: json['folder_id'] as String?,
      position: json['position'] as int? ?? 0,
    );
  }
}

class FolderTreeModel {
  final String id;
  final String name;
  final String? parentId;
  final List<FolderTreeModel> subfolders;
  final List<BookmarkModel> bookmarks;

  FolderTreeModel({
    required this.id,
    required this.name,
    this.parentId,
    this.subfolders = const [],
    this.bookmarks = const [],
  });

  factory FolderTreeModel.fromJson(Map<String, dynamic> json) {
    return FolderTreeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parent_id'] as String?,
      subfolders: (json['subfolders'] as List<dynamic>?)
              ?.map((e) => FolderTreeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bookmarks: (json['bookmarks'] as List<dynamic>?)
              ?.map((e) => BookmarkModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
