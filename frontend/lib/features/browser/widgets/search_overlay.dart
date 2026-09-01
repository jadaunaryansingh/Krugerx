import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchOverlay extends ConsumerWidget {
  final String query;
  final VoidCallback onClose;

  const SearchOverlay({super.key, required this.query, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: DesignSystem.background.withValues(alpha: 0.85),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClose,
                  ),
                ),
              ),
              Expanded(
                child: query.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded,
                                size: 40,
                                color: DesignSystem.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'Trending Searches',
                              style: TextStyle(
                                color: DesignSystem.onSurfaceVariant,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _suggestionTile(
                            icon: Icons.search_rounded,
                            title: query,
                            subtitle: 'Search Google',
                            onTap: onClose,
                          ),
                          _suggestionTile(
                            icon: Icons.search_rounded,
                            title: '$query example',
                            onTap: onClose,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: DesignSystem.onSurfaceVariant, size: 20),
          title: Text(title,
              style: const TextStyle(
                  color: DesignSystem.onSurface, fontSize: 14)),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style: TextStyle(
                      color: DesignSystem.onSurfaceVariant, fontSize: 12))
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          hoverColor: DesignSystem.primary.withValues(alpha: 0.06),
          onTap: onTap,
        ),
      ),
    );
  }
}




