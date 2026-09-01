class AiMessageModel {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;

  AiMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AiSessionModel {
  final String id;
  final String title;
  final String provider;
  final String model;

  AiSessionModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.model,
  });

  factory AiSessionModel.fromJson(Map<String, dynamic> json) {
    return AiSessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      model: json['model'] as String,
    );
  }
}
