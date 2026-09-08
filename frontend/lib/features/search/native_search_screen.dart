import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/theme/design_system.dart';
import '../../core/providers/tabs_provider.dart';
import '../../core/constants.dart';
import 'models/search_models.dart';

final nativeSearchProvider = FutureProvider.family<SearchResponse, String>((ref, query) async {
  final url = '${AppConstants.apiBaseUrl}/search?q=${Uri.encodeComponent(query)}';
  final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return SearchResponse.fromJson(data['data']);
    }
  }
  throw Exception('Failed to load search results');
});

class NativeSearchScreen extends ConsumerStatefulWidget {
  final String query;

  const NativeSearchScreen({super.key, required this.query});

  @override
  ConsumerState<NativeSearchScreen> createState() => _NativeSearchScreenState();
}

class _NativeSearchScreenState extends ConsumerState<NativeSearchScreen> {
  late TextEditingController _searchController;
  String _activeTab = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(NativeSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.trim().isNotEmpty) {
      final tabs = ref.read(tabsProvider);
      ref.read(tabsProvider.notifier).updateTabUrl(tabs.activeIndex, 'kruger://search?q=${Uri.encodeComponent(query.trim())}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(nativeSearchProvider(widget.query));

    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          const Divider(height: 1, color: DesignSystem.outlineVariant),
          Expanded(
            child: searchResult.when(
              data: (data) => _buildContent(data),
              loading: () => const Center(child: CircularProgressIndicator(color: DesignSystem.primary)),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $err', style: const TextStyle(color: DesignSystem.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(nativeSearchProvider(widget.query)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 32, right: 32, bottom: 16),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.public, color: DesignSystem.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                'KrugerSearch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()..shader = const LinearGradient(colors: [DesignSystem.primary, DesignSystem.primaryDim]).createShader(const Rect.fromLTWH(0, 0, 150, 24)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Container(
              height: 48,
              constraints: const BoxConstraints(maxWidth: 720),
              decoration: BoxDecoration(
                color: DesignSystem.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DesignSystem.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: DesignSystem.onSurface, fontSize: 16),
                      onSubmitted: _submitSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search the web...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: DesignSystem.onSurfaceVariant),
                    onPressed: () => _submitSearch(_searchController.text),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
          const Icon(Icons.settings_outlined, color: DesignSystem.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['All', 'Images', 'News', 'Videos', 'Maps'];
    return Padding(
      padding: const EdgeInsets.only(left: 280), // Align with search bar roughly
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _activeTab == tab;
          return InkWell(
            onTap: () => setState(() => _activeTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? DesignSystem.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? DesignSystem.onSurface : DesignSystem.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(SearchResponse data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left offset to align with search bar
        const SizedBox(width: 140),
        
        // Search Results
        Expanded(
          flex: 5,
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 24, bottom: 64, right: 32),
            itemCount: data.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 32),
            itemBuilder: (context, index) {
              return _buildResultItem(data.results[index]);
            },
          ),
        ),

        // Knowledge Panel
        if (data.knowledgePanel != null) ...[
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, right: 140),
              child: _buildKnowledgePanel(data.knowledgePanel!),
            ),
          ),
        ] else ...[
          const Expanded(flex: 3, child: SizedBox()),
        ],
      ],
    );
  }

  Widget _buildResultItem(SearchResultItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            final tabs = ref.read(tabsProvider);
            ref.read(tabsProvider.notifier).updateTabUrl(tabs.activeIndex, item.url);
          },
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: DesignSystem.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.favicon != null 
                    ? Image.network(item.favicon!, errorBuilder: (_, _, _) => const Icon(Icons.language, size: 16, color: DesignSystem.onSurfaceVariant))
                    : const Icon(Icons.language, size: 16, color: DesignSystem.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 14, color: DesignSystem.onSurface, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.url,
                      style: const TextStyle(fontSize: 12, color: DesignSystem.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            final tabs = ref.read(tabsProvider);
            ref.read(tabsProvider.notifier).updateTabUrl(tabs.activeIndex, item.url);
          },
          child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF8AB4F8), // A nice link blue
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.snippet,
          style: const TextStyle(fontSize: 14, color: DesignSystem.onSurfaceVariant, height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildKnowledgePanel(KnowledgePanel panel) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignSystem.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (panel.imageUrl != null)
            Image.network(
              panel.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  panel.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DesignSystem.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  panel.description,
                  style: const TextStyle(fontSize: 14, color: DesignSystem.onSurfaceVariant, height: 1.5),
                ),
                if (panel.attributes != null) ...[
                  const SizedBox(height: 24),
                  const Divider(color: DesignSystem.outlineVariant, height: 1),
                  const SizedBox(height: 16),
                  ...panel.attributes!.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 13, color: DesignSystem.onSurfaceVariant, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value.toString(),
                            style: const TextStyle(fontSize: 13, color: DesignSystem.onSurface),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                if (panel.url != null) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      final tabs = ref.read(tabsProvider);
                      ref.read(tabsProvider.notifier).updateTabUrl(tabs.activeIndex, panel.url!);
                    },
                    child: const Text(
                      'More about this topic \u2192',
                      style: TextStyle(fontSize: 13, color: DesignSystem.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}



