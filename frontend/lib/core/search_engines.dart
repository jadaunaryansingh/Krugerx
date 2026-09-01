/// Search engine URL templates.
/// Each value is a URL with `%s` where the query goes.
const searchEngines = <String, String>{
  'google':     'https://www.google.com/search?q=%s',
  'bing':       'https://www.bing.com/search?q=%s',
  'duckduckgo': 'https://duckduckgo.com/?q=%s',
  'brave':      'https://search.brave.com/search?q=%s',
};

String buildSearchUrl(String engine, String query) {
  final template = searchEngines[engine] ?? searchEngines['google']!;
  return template.replaceFirst('%s', Uri.encodeComponent(query));
}
