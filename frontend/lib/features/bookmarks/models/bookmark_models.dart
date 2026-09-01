import 'package:isar_community/isar.dart';

part 'bookmark_models.g.dart';

@collection
class LocalBookmark {
  Id id = Isar.autoIncrement;

  @Index()
  String? remoteId;

  String title = '';
  String url = '';
  String? folderId;
  int position = 0;
  bool synced = false;
  DateTime createdAt = DateTime.now();
}

@collection
class LocalFolder {
  Id id = Isar.autoIncrement;

  @Index()
  String? remoteId;

  String name = '';
  String? parentId;
  bool synced = false;
}
