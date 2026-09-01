import 'package:isar_community/isar.dart';

part 'download_models.g.dart';

@collection
class LocalDownload {
  Id id = Isar.autoIncrement;

  String? remoteId;
  String filename = '';
  String url = '';
  String status = 'queued'; // queued, downloading, completed, failed, cancelled
  double progress = 0.0;
  int? totalBytes;
  int? downloadedBytes;
  String? localPath;
  DateTime createdAt = DateTime.now();
  DateTime? completedAt;
}
