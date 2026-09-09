import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/bookmarks_provider.dart';
import '../../core/models/bookmark.dart';
import '../../core/theme/design_system.dart';
import 'package:go_router/go_router.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookmarksProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(bookmarksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              foregroundColor: DesignSystem.primary,
            ),
            onPressed: () {
              _showAddBookmarkDialog();
            },
          ),
        ],
      ),
      body: folders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DesignSystem.surfaceContainer,
                      border: Border.all(color: DesignSystem.outlineVariant),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded,
                        size: 28, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text('No bookmarks yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: DesignSystem.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('Save your favorite pages here',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return _buildFolder(folder, theme);
              },
            ),
    );
  }

  Widget _buildFolder(FolderTreeModel folder, ThemeData theme) {
    return ExpansionTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: DesignSystem.primary.withValues(alpha: 0.1),
        ),
        child: const Icon(Icons.folder_rounded,
            size: 18, color: DesignSystem.primary),
      ),
      title: Text(folder.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      children: [
        for (var sub in folder.subfolders)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _buildFolder(sub, theme),
          ),
        for (var bm in folder.bookmarks)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 48, right: 16),
                leading: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(4.0),
                    color: DesignSystem.surfaceContainerHigh,
                  ),
                  child: const Icon(Icons.public, size: 14,
                      color: DesignSystem.onSurfaceVariant),
                ),
                title: Text(bm.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
                subtitle: Text(bm.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11, color: DesignSystem.onSurfaceVariant)),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(4.0),
                ),
                hoverColor: DesignSystem.primary.withValues(alpha: 0.06),
                onTap: () {
                  context.go('/browser', extra: {
                    'url': bm.url,
                    'title': bm.title,
                    'consumed': false,
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showAddBookmarkDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController(text: 'https://');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarksProvider.notifier).addBookmark(
                titleController.text.trim(),
                urlController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}




