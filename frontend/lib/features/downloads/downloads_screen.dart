import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/downloads_provider.dart';
import '../../core/theme/design_system.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(downloadsProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(downloadsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: list.isEmpty
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
                    child: const Icon(Icons.download_rounded,
                        size: 28, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text('No downloads',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: DesignSystem.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('Your downloads will appear here',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DesignSystem.surfaceContainer,
                    borderRadius:
                        BorderRadius.circular(12.0),
                    border: Border.all(color: DesignSystem.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              8.0),
                          color: DesignSystem.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.insert_drive_file_rounded,
                            size: 20, color: DesignSystem.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.filename,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(item.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: DesignSystem.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: item.progress,
                                  backgroundColor:
                                      DesignSystem.surfaceContainerHighest,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          DesignSystem.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _statusChip(item.status),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = DesignSystem.primary;
        break;
      case 'downloading':
        color = DesignSystem.primary;
        break;
      case 'failed':
        color = DesignSystem.error;
        break;
      default:
        color = DesignSystem.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}




