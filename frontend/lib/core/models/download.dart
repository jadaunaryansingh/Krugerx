class DownloadModel {
  final String id;
  final String filename;
  final String url;
  final String status;
  final double progress;
  final int? totalBytes;
  final int? downloadedBytes;
  final DateTime? completedTime;

  DownloadModel({
    required this.id,
    required this.filename,
    required this.url,
    required this.status,
    required this.progress,
    this.totalBytes,
    this.downloadedBytes,
    this.completedTime,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'] as String,
      filename: json['filename'] as String,
      url: json['url'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble(),
      totalBytes: json['total_bytes'] as int?,
      downloadedBytes: json['downloaded_bytes'] as int?,
      completedTime: json['completed_time'] != null
          ? DateTime.parse(json['completed_time'] as String)
          : null,
    );
  }
}
