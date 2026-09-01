import 'package:isar_community/isar.dart';

part 'history_models.g.dart';

@collection
class LocalHistory {
  Id id = Isar.autoIncrement;

  String? remoteId;

  @Index()
  String url = '';

  String? title;

  @Index()
  DateTime visitTime = DateTime.now();

  int visitCount = 1;
  bool synced = false;
}
