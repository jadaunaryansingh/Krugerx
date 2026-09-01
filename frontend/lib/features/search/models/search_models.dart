class SearchResultItem {
  final String title;
  final String url;
  final String snippet;
  final String? favicon;

  SearchResultItem({
    required this.title,
    required this.url,
    required this.snippet,
    this.favicon,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      favicon: json['favicon'] as String?,
    );
  }
}

class KnowledgePanel {
  final String title;
  final String description;
  final String? imageUrl;
  final String? url;
  final Map<String, dynamic>? attributes;

  KnowledgePanel({
    required this.title,
    required this.description,
    this.imageUrl,
    this.url,
    this.attributes,
  });

  factory KnowledgePanel.fromJson(Map<String, dynamic> json) {
    return KnowledgePanel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      url: json['url'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );
  }
}

class SearchResponse {
  final String provider;
  final String query;
  final List<SearchResultItem> results;
  final KnowledgePanel? knowledgePanel;

  SearchResponse({
    required this.provider,
    required this.query,
    required this.results,
    this.knowledgePanel,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List<dynamic>? ?? [];
    return SearchResponse(
      provider: json['provider'] as String? ?? '',
      query: json['query'] as String? ?? '',
      results: resultsList.map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>)).toList(),
      knowledgePanel: json['knowledge_panel'] != null 
          ? KnowledgePanel.fromJson(json['knowledge_panel'] as Map<String, dynamic>) 
          : null,
    );
  }
}
