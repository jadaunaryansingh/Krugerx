import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';
import '../../../theme.dart';
import '../../../core/widgets/hover_scale_widget.dart';

class TabStrip extends ConsumerWidget {
  const TabStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(browserProvider);
    final notifier = ref.read(browserProvider.notifier);
    final isIncognito = state.activeTab.isIncognito;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          decoration: BoxDecoration(
            color: isIncognito
                ? KrugerXTheme.incognitoColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.2), // Glassmorphic translucent background
            border: Border(
              bottom: BorderSide(
                color: isIncognito
                    ? KrugerXTheme.incognitoColor.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1), // Subtle border
                width: 1.0,
              ),
            ),
          ),
      child: Row(
        children: [
          if (isIncognito) ...[
            const SizedBox(width: 10),
            Icon(Icons.visibility_off_rounded, size: 13,
                color: KrugerXTheme.incognitoColor.withValues(alpha: 0.8)),
          ],
          const SizedBox(width: 6),
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: state.tabs.length,
              onReorder: notifier.reorderTabs,
              proxyDecorator: (child, index, animation) => child,
              buildDefaultDragHandles: false,
              itemBuilder: (context, i) {
                final tab = state.tabs[i];
                return Padding(
                  key: ValueKey(tab.id),
                  padding: const EdgeInsets.only(right: 3),
                  child: ReorderableDragStartListener(
                    index: i,
                    child: _TabChip(
                      tab: tab,
                      isActive: i == state.activeIndex,
                      onTap: () => notifier.switchTab(i),
                      onClose: () {
                        notifier.closeTab(i);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tab closed',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.surface, // dark theme
                            behavior: SnackBarBehavior.floating,
                            width: 250,
                            duration: const Duration(seconds: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: KrugerXTheme.primary.withValues(alpha: 0.5)),
                            ),
                            action: SnackBarAction(
                              label: 'UNDO',
                              textColor: KrugerXTheme.primary,
                              onPressed: () => notifier.undoCloseTab(),
                            ),
                          ),
                        );
                      },
                      onTogglePin: () => notifier.togglePinTab(i),
                      onToggleMute: () => notifier.toggleMuteTab(i),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 2),
          // New tab button
          _TabStripAction(
            icon: Icons.add_rounded,
            tooltip: 'New tab',
            onTap: notifier.addTab,
          ),
          // Incognito tab button
          _TabStripAction(
            icon: Icons.visibility_off_outlined,
            tooltip: 'New incognito tab',
            onTap: () => notifier.addTab(incognito: true),
          ),
          const SizedBox(width: 4),
        ],
      ),
    ),
    ),
    );
  }
}

class _TabStripAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TabStripAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: IconButton(
          icon: Icon(icon, size: 16),
          padding: EdgeInsets.zero,
          onPressed: onTap,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Individual Tab Chip ────────────────────────────────────────────────────

class _TabChip extends StatefulWidget {
  final dynamic tab; // TabModel
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleMute;

  const _TabChip({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
    required this.onTogglePin,
    required this.onToggleMute,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  bool _hovering = false;

  void _showContextMenu(BuildContext context, Offset position) {
    final colors = Theme.of(context).colorScheme;
    final tab = widget.tab;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: KrugerXTheme.primary.withValues(alpha: 0.3)),
      ),
      items: [
        PopupMenuItem(
          onTap: widget.onTogglePin,
          child: Text(
            tab.isPinned ? 'Unpin Tab' : 'Pin Tab',
            style: TextStyle(color: colors.onSurface, fontSize: 13),
          ),
        ),
        PopupMenuItem(
          onTap: widget.onToggleMute,
          child: Text(
            tab.isMuted ? 'Unmute Tab' : 'Mute Tab',
            style: TextStyle(color: colors.onSurface, fontSize: 13),
          ),
        ),
        PopupMenuItem(
          onTap: widget.onClose,
          child: Text(
            'Close Tab',
            style: TextStyle(color: colors.error, fontSize: 13),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tab = widget.tab;
    final isIncognito = tab.isIncognito as bool;
    final isPinned = tab.isPinned as bool;
    final isMuted = tab.isMuted as bool;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapDown: (details) => _showContextMenu(context, details.globalPosition),
        onLongPressStart: (details) => _showContextMenu(context, details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: BoxConstraints(
            maxWidth: isPinned ? 50 : 190,
            minWidth: isPinned ? 50 : 72,
          ),
          padding: EdgeInsets.symmetric(horizontal: isPinned ? 0 : 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? (isIncognito
                    ? KrugerXTheme.incognitoColor.withValues(alpha: 0.25)
                    : colors.surfaceContainerHigh)
                : (_hovering ? colors.surfaceContainer : colors.surfaceContainerLowest),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive
                  ? (isIncognito
                      ? KrugerXTheme.incognitoColor.withValues(alpha: 0.5)
                      : KrugerXTheme.primary.withValues(alpha: 0.5))
                  : colors.outline.withValues(alpha: _hovering ? 0.6 : 0.3),
              width: widget.isActive ? 1 : 0.5,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: (isIncognito ? KrugerXTheme.incognitoColor : KrugerXTheme.primary)
                          .withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isPinned ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              // Favicon or indicator dot
              _TabFavicon(faviconUrl: tab.faviconUrl as String?, isIncognito: isIncognito, isActive: widget.isActive),
              if (!isPinned) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    tab.title as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isActive ? colors.onSurface : colors.onSurfaceVariant,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMuted) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.volume_off_rounded, size: 12, color: colors.onSurfaceVariant),
                ],
                const SizedBox(width: 4),
                HoverScaleWidget(
                  scaleFactor: 0.9,
                  onTap: widget.onClose,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _hovering || widget.isActive ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _TabFavicon extends StatelessWidget {
  final String? faviconUrl;
  final bool isIncognito;
  final bool isActive;

  const _TabFavicon({this.faviconUrl, required this.isIncognito, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isIncognito) {
      return Icon(Icons.visibility_off_rounded, size: 11,
          color: KrugerXTheme.incognitoColor.withValues(alpha: 0.8));
    }

    if (faviconUrl != null && faviconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          faviconUrl!,
          width: 12,
          height: 12,
          errorBuilder: (_, _, _) => _dot(colors),
          fit: BoxFit.cover,
        ),
      );
    }

    return _dot(colors);
  }

  Widget _dot(ColorScheme colors) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? KrugerXTheme.primary
              : colors.onSurfaceVariant.withValues(alpha: 0.35),
        ),
      );
}

