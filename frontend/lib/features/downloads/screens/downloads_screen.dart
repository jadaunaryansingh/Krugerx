import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/downloads_provider.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear completed',
            onPressed: () => ref.read(downloadsProvider.notifier).clearCompleted(),
          ),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_done_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No recent downloads', style: TextStyle(color: colors.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: downloads.length,
              itemBuilder: (context, i) {
                final d = downloads[i];
                final isDone = d.status == 'completed';
                
                return ListTile(
                  leading: Icon(
                    isDone ? Icons.insert_drive_file_rounded : Icons.download_rounded,
                    color: isDone ? colors.primary : colors.secondary,
                  ),
                  title: Text(d.filename, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                      if (!isDone)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: d.progress,
                            backgroundColor: colors.surfaceContainerHigh,
                            valueColor: AlwaysStoppedAnimation(colors.secondary),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
