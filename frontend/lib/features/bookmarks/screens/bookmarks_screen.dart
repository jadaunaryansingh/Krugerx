import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bookmarks_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarksProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: state.bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No bookmarks yet', style: TextStyle(color: colors.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.bookmarks.length,
              itemBuilder: (context, i) {
                final bm = state.bookmarks[i];
                return Dismissible(
                  key: ValueKey(bm.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: colors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(bookmarksProvider.notifier).deleteBookmark(bm.id);
                  },
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.public_rounded, size: 20, color: colors.primary),
                    ),
                    title: Text(bm.title.isNotEmpty ? bm.title : bm.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(bm.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    onTap: () {
                      // Navigate in browser - handled via provider or routing in real app
                      context.go('/', extra: bm.url);
                    },
                  ),
                );
              },
            ),
    );
  }
}
