import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bookmark.dart';
import 'auth_provider.dart';

final bookmarksProvider = NotifierProvider<BookmarksNotifier, List<FolderTreeModel>>(BookmarksNotifier.new);

class BookmarksNotifier extends Notifier<List<FolderTreeModel>> {
  @override
  List<FolderTreeModel> build() => const [];

  Future<void> fetch() async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.get('/bookmarks/folders/tree');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((e) => FolderTreeModel.fromJson(e))
            .toList();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> addBookmark(String title, String url, {String? folderId}) async {
    final api = ref.read(apiClientProvider);
    try {
      await api.dio.post('/bookmarks', data: {
        'title': title,
        'url': url,
        if (folderId != null) 'folder_id': folderId,
      });
      await fetch();
    } catch (_) {}
  }
}
