import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import 'providers/downloads_provider.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = ref.watch(downloadsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'SYS.DOWNLOADS',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            color: DesignSystem.primary,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (list.any((d) => d.status == 'completed'))
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              color: DesignSystem.primary,
              tooltip: 'Clear completed',
              onPressed: () =>
                  ref.read(downloadsProvider.notifier).clearCompleted(),
            ),
        ],
      ),
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
                      color: const Color(0xFF111111),
                      border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.download_rounded,
                        size: 28, color: DesignSystem.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NO_DOWNLOADS',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: DesignSystem.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your downloads will appear here',
                    style: TextStyle(color: Color(0xFF555555), fontSize: 12),
                  ),
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
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: const Color(0xFF111111),
                          border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.insert_drive_file_rounded,
                            size: 20, color: DesignSystem.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.filename,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: DesignSystem.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 3,
                                child: LinearProgressIndicator(
                                  value: item.progress,
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
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
    final Color color = switch (status.toLowerCase()) {
      'completed' => DesignSystem.primary,
      'downloading' => DesignSystem.primary,
      'failed' => DesignSystem.error,
      _ => DesignSystem.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'JetBrains Mono',
          letterSpacing: 1,
        ),
      ),
    );
  }
}
