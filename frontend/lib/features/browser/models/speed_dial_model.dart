import 'package:isar_community/isar.dart';

part 'speed_dial_model.g.dart';

@collection
class SpeedDialEntry {
  Id id = Isar.autoIncrement;

  String name = '';
  String url = '';
  String? iconName; // Material icon name for fallback
  int position = 0;
  DateTime createdAt = DateTime.now();
}
