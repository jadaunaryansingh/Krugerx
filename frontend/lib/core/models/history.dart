class HistoryModel {
  final String id;
  final String url;
  final String? title;
  final DateTime visitTime;
  final int visitCount;

  HistoryModel({
    required this.id,
    required this.url,
    this.title,
    required this.visitTime,
    this.visitCount = 1,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      visitTime: DateTime.parse(json['visit_time'] as String),
      visitCount: json['visit_count'] as int? ?? 1,
    );
  }
}
