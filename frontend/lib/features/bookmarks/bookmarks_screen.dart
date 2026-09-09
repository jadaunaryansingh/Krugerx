import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import 'providers/bookmarks_provider.dart';
import 'package:go_router/go_router.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final bmState = ref.watch(bookmarksProvider);
    final bookmarks = bmState.bookmarks;

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'SYS.BOOKMARKS',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            color: DesignSystem.primary,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: DesignSystem.primary,
            tooltip: 'Add bookmark',
            onPressed: _showAddBookmarkDialog,
          ),
        ],
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF111111),
                      border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded,
                        size: 28, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NO_BOOKMARKS',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: DesignSystem.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Save your favorite pages here',
                    style: TextStyle(color: Color(0xFF555555), fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bm = bookmarks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: const Color(0xFF111111),
                          border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.bookmark_rounded,
                            size: 16, color: DesignSystem.primary),
                      ),
                      title: Text(
                        bm.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        bm.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: DesignSystem.onSurfaceVariant),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        color: DesignSystem.primary.withValues(alpha: 0.5),
                        onPressed: () =>
                            ref.read(bookmarksProvider.notifier).deleteBookmark(bm.id),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.08)),
                      ),
                      tileColor: const Color(0xFF0D0D0D),
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
                );
              },
            ),
    );
  }

  void _showAddBookmarkDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'https://');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'ADD_BOOKMARK',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            color: DesignSystem.primary,
            fontSize: 14,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(titleCtrl, 'Title'),
            const SizedBox(height: 12),
            _field(urlCtrl, 'URL'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF777777))),
          ),
          TextButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              final u = urlCtrl.text.trim();
              if (t.isNotEmpty && u.isNotEmpty) {
                ref.read(bookmarksProvider.notifier).addBookmark(t, u);
              }
              Navigator.pop(ctx);
            },
            child: const Text('ADD', style: TextStyle(color: DesignSystem.primary)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) => TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: DesignSystem.onSurfaceVariant),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.3)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: DesignSystem.primary),
          ),
        ),
      );
}
