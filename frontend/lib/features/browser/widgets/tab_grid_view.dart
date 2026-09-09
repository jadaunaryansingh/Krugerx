import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';
import '../../../core/theme/design_system.dart';

/// Visual grid overview of all open tabs — like Chrome mobile's tab switcher.
class TabGridView extends ConsumerWidget {
  final VoidCallback onNewTab;
  final void Function(bool incognito) onNewTabWith;

  const TabGridView({super.key, required this.onNewTab, required this.onNewTabWith});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(browserProvider);
    final notifier = ref.read(browserProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Text(
                    '${state.tabs.length} ${state.tabs.length == 1 ? 'Tab' : 'Tabs'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.add_rounded, color: DesignSystem.brandGold),
                    onPressed: onNewTab,
                    tooltip: 'New Tab',
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility_off_rounded, color: DesignSystem.incognitoColor, size: 20),
                    onPressed: () => onNewTabWith(true),
                    tooltip: 'New Incognito Tab',
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                    onPressed: () => notifier.toggleTabGrid(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: state.tabs.length,
                itemBuilder: (context, i) {
                  final tab = state.tabs[i];
                  final isActive = i == state.activeIndex;
                  return _TabGridCard(
                    tab: tab,
                    isActive: isActive,
                    onTap: () => notifier.switchTab(i),
                    onClose: () => notifier.closeTab(i),
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: 50 * i),
                    duration: 250.ms,
                  ).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    delay: Duration(milliseconds: 50 * i),
                    duration: 250.ms,
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}

class _TabGridCard extends StatefulWidget {
  final dynamic tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabGridCard({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_TabGridCard> createState() => _TabGridCardState();
}

class _TabGridCardState extends State<_TabGridCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tab = widget.tab;
    final isIncognito = tab.isIncognito as bool;
    final title = tab.title as String;
    final url = tab.url as String;

    final borderColor = widget.isActive
        ? (isIncognito ? DesignSystem.incognitoColor : DesignSystem.brandGold)
        : colors.outline;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.98 : 1.0,
          _pressed ? 0.98 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isIncognito
              ? DesignSystem.incognitoColor.withValues(alpha: 0.12)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withValues(alpha: widget.isActive ? 0.8 : 0.3),
            width: widget.isActive ? 2 : 0.5,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab header with close
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 0),
              child: Row(
                children: [
                  if (isIncognito)
                    Icon(Icons.visibility_off_rounded, size: 12,
                        color: DesignSystem.incognitoColor.withValues(alpha: 0.8))
                  else
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isActive ? DesignSystem.brandGold : colors.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close_rounded, size: 14,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
            // Page preview area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: url.isEmpty
                      ? colors.surfaceContainerHigh.withValues(alpha: 0.5)
                      : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.outline.withValues(alpha: 0.2), width: 0.5),
                ),
                child: url.isEmpty
                    ? Center(
                        child: Icon(Icons.language_rounded, size: 32,
                            color: DesignSystem.brandGold.withValues(alpha: 0.3)),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.public_rounded, size: 28, color: colors.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              _extractDomain(url),
                              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant.withValues(alpha: 0.6)),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractDomain(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }
}
