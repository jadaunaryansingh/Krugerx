import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final historyList = ref.watch(historyProvider).where((e) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return e.url.toLowerCase().contains(query) || (e.title?.toLowerCase().contains(query) ?? false);
    }).toList();
    
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          if (ref.read(historyProvider).isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear history',
              onPressed: () => ref.read(historyProvider.notifier).clearAll(),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: historyList.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No browsing history', style: TextStyle(color: colors.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: historyList.length,
              itemBuilder: (context, i) {
                final entry = historyList[i];
                final timeStr = DateFormat.jm().format(entry.visitTime);
                final dateStr = DateFormat.MMMd().format(entry.visitTime);

                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: colors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(historyProvider.notifier).deleteEntry(entry.id);
                  },
                  child: ListTile(
                    leading: Icon(Icons.language_rounded, color: colors.onSurfaceVariant),
                    title: Text(entry.title?.isNotEmpty == true ? entry.title! : entry.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(entry.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    trailing: Text('$dateStr\n$timeStr', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    onTap: () {
                      context.go('/', extra: entry.url);
                    },
                  ),
                );
              },
            ),
    );
  }
}
