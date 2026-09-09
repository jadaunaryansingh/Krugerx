import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../history/providers/history_provider.dart';
import '../../../core/theme/design_system.dart';

/// Browsing stats card for the home page â€” sites visited today, top domains.
class StatsCard extends ConsumerWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(historyProvider);
    final colors = Theme.of(context).colorScheme;

    // Compute today's stats
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayEntries = historyList.where((e) => e.visitTime.isAfter(today)).toList();
    final uniqueDomains = <String>{};
    for (final e in todayEntries) {
      try {
        uniqueDomains.add(Uri.parse(e.url).host);
      } catch (e) {
        debugPrint('[StatsCard] Error parsing URL for domain: $e');
      }
    }

    if (todayEntries.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignSystem.brandGold.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 14, color: DesignSystem.brandGold),
              const SizedBox(width: 6),
              Text(
                'TODAY\'S BROWSING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: DesignSystem.brandGold.withValues(alpha: 0.8),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(
                value: '${todayEntries.length}',
                label: 'Pages',
                icon: Icons.web_rounded,
              ),
              const SizedBox(width: 10),
              _StatPill(
                value: '${uniqueDomains.length}',
                label: 'Sites',
                icon: Icons.dns_rounded,
              ),
              const SizedBox(width: 10),
              _StatPill(
                value: '${todayEntries.fold<int>(0, (sum, e) => sum + e.visitCount)}',
                label: 'Visits',
                icon: Icons.touch_app_rounded,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatPill({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: DesignSystem.brandGold.withValues(alpha: 0.6)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: colors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
