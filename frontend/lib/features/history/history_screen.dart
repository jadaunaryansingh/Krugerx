import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import 'providers/history_provider.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'SYS.HISTORY',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            color: DesignSystem.primary,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: DesignSystem.primary,
            tooltip: 'Clear all history',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text(
                    'CLEAR_HISTORY?',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: DesignSystem.primary,
                      fontSize: 14,
                    ),
                  ),
                  content: const Text(
                    'This will permanently delete all local history.',
                    style: TextStyle(color: Color(0xFFAAAAAA)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('CANCEL', style: TextStyle(color: Color(0xFF777777))),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(historyProvider.notifier).clearAll();
                        Navigator.pop(ctx);
                      },
                      child: const Text('CONFIRM', style: TextStyle(color: DesignSystem.primary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: historyList.isEmpty
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
                    child: const Icon(Icons.history_rounded,
                        size: 28, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NO_HISTORY',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: DesignSystem.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pages you visit will appear here',
                    style: TextStyle(color: Color(0xFF555555), fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
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
                        child: const Icon(Icons.public,
                            size: 16, color: DesignSystem.onSurfaceVariant),
                      ),
                      title: Text(
                        item.title ?? item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11,
                            color: DesignSystem.onSurfaceVariant),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(item.visitTime),
                            style: const TextStyle(
                              fontSize: 11,
                              color: DesignSystem.onSurfaceVariant,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                          if (item.visitCount > 1)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: DesignSystem.primary.withValues(alpha: 0.1),
                                border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              child: Text(
                                '${item.visitCount}×',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: DesignSystem.primary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.08)),
                      ),
                      tileColor: const Color(0xFF0D0D0D),
                      hoverColor: DesignSystem.primary.withValues(alpha: 0.06),
                      onTap: () {
                        context.go('/browser', extra: {
                          'url': item.url,
                          'title': item.title,
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

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${local.day}/${local.month}/${local.year}';
  }
}

