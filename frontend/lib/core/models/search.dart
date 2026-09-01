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
      title: json['title'] as String,
      url: json['url'] as String,
      snippet: json['snippet'] as String,
      favicon: json['favicon'] as String?,
    );
  }
}

class SearchResponse {
  final String provider;
  final String query;
  final List<SearchResultItem> results;

  SearchResponse({
    required this.provider,
    required this.query,
    required this.results,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      provider: json['provider'] as String,
      query: json['query'] as String,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
