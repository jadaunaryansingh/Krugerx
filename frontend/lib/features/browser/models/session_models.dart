import 'package:isar_community/isar.dart';

part 'session_models.g.dart';

@collection
class LocalSessionTab {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String tabId;

  late String url;
  String? title;
  
  late DateTime timestamp;

  bool isPinned = false;
  bool isMuted = false;
  
  String? groupId;
  double zoomScale = 1.0;
  
  int position = 0;
}
