import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/history_provider.dart';
import '../../core/theme/design_system.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final historyList = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            style: IconButton.styleFrom(
              foregroundColor: DesignSystem.error.withValues(alpha: 0.8),
            ),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
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
                      color: DesignSystem.surfaceContainer,
                      border: Border.all(color: DesignSystem.outlineVariant),
                    ),
                    child: const Icon(Icons.history_rounded,
                        size: 28, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text('No history',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: DesignSystem.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('Pages you visit will show up here',
                      style: theme.textTheme.bodySmall),
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
                          borderRadius:
                              BorderRadius.circular(4.0),
                          color: DesignSystem.surfaceContainerHigh,
                          border: Border.all(color: DesignSystem.outlineVariant),
                        ),
                        child: const Icon(Icons.public,
                            size: 16, color: DesignSystem.onSurfaceVariant),
                      ),
                      title: Text(
                        item.title ?? item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: DesignSystem.onSurfaceVariant),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(item.visitTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: DesignSystem.onSurfaceVariant,
                            ),
                          ),
                          if (item.visitCount > 1)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    DesignSystem.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    32.0),
                              ),
                              child: Text(
                                '${item.visitCount}×',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: DesignSystem.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4.0),
                      ),
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




