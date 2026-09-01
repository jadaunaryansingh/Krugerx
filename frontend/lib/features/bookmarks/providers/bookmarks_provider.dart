import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/storage.dart';
import '../models/bookmark_models.dart';

class BookmarksState {
  final List<LocalFolder> folders;
  final List<LocalBookmark> bookmarks;

  const BookmarksState({this.folders = const [], this.bookmarks = const []});
}

class BookmarksNotifier extends Notifier<BookmarksState> {
  @override
  BookmarksState build() {
    _watchData();
    return const BookmarksState();
  }

  void _watchData() {
    _fetch();
    Storage.db.localBookmarks.watchLazy().listen((_) => _fetch());
    Storage.db.localFolders.watchLazy().listen((_) => _fetch());
  }

  Future<void> _fetch() async {
    final folders = await Storage.db.localFolders.where().findAll();
    final bookmarks = await Storage.db.localBookmarks.where().sortByPosition().findAll();
    state = BookmarksState(folders: folders, bookmarks: bookmarks);
  }

  Future<void> addBookmark(String title, String url, {String? folderId}) async {
    final bookmark = LocalBookmark()
      ..title = title
      ..url = url
      ..folderId = folderId
      ..position = state.bookmarks.length
      ..synced = false;

    await Storage.db.writeTxn(() async {
      await Storage.db.localBookmarks.put(bookmark);
    });
  }

  Future<void> deleteBookmark(int id) async {
    await Storage.db.writeTxn(() async {
      await Storage.db.localBookmarks.delete(id);
    });
  }

  Future<void> addFolder(String name, {String? parentId}) async {
    final folder = LocalFolder()
      ..name = name
      ..parentId = parentId
      ..synced = false;

    await Storage.db.writeTxn(() async {
      await Storage.db.localFolders.put(folder);
    });
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, BookmarksState>(BookmarksNotifier.new);
