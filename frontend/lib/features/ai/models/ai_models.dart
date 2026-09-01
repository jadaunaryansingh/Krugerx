import 'package:isar_community/isar.dart';

part 'ai_models.g.dart';

@collection
class LocalChatSession {
  Id id = Isar.autoIncrement;
  String? remoteId;
  String title = '';
  String provider = '';
  String model = '';
  DateTime updatedAt = DateTime.now();
  bool synced = false;
}

@collection
class LocalChatMessage {
  Id id = Isar.autoIncrement;
  String? remoteId;
  int sessionId = 0;
  String role = 'user'; // user, assistant, system
  String content = '';
  DateTime createdAt = DateTime.now();
  bool synced = false;
}
