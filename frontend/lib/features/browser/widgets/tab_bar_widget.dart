import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/tabs_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/hover_scale_widget.dart';

class TabBarWidget extends ConsumerWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsProvider);

    return Container(
      height: 40,
      color: Colors.black,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabsState.tabs.length,
              onReorder: ref.read(tabsProvider.notifier).reorderTabs,
              proxyDecorator: (child, index, animation) => child,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final tab = tabsState.tabs[index];
                final isActive = index == tabsState.activeIndex;

                return ReorderableDragStartListener(
                  key: ValueKey(tab.id),
                  index: index,
                  child: HoverScaleWidget(
                    onTap: () => ref.read(tabsProvider.notifier).switchTab(index),
                    scaleFactor: 0.97,
                    child: Container(
                      margin: EdgeInsets.zero,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 192, // w-48
                        padding: const EdgeInsets.only(left: 32, right: 16, top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF1A1A1A) : const Color(0xFF111111),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          border: isActive ? Border(bottom: BorderSide(color: DesignSystem.primary, width: 2)) : null,
                          boxShadow: isActive ? [BoxShadow(color: DesignSystem.primary.withValues(alpha: 0.1), blurRadius: 10)] : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.terminal,
                              size: 14,
                              color: isActive ? DesignSystem.primary : DesignSystem.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (tab.title?.isEmpty ?? true) ? 'System Diag' : tab.title!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DesignSystem.dataMono.copyWith(
                                  fontSize: 10,
                                  color: isActive ? DesignSystem.primary : DesignSystem.onSurfaceVariant,
                                  letterSpacing: 2.0, // tracking-widest
                                ),
                              ),
                            ),
                            if (tabsState.tabs.length > 1)
                              HoverScaleWidget(
                                onTap: () {
                                  ref.read(tabsProvider.notifier).closeTab(index);
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tab closed',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                      backgroundColor: const Color(0xFF272727), // surface1
                                      behavior: SnackBarBehavior.floating,
                                      width: 250,
                                      duration: const Duration(seconds: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.5)),
                                      ),
                                      action: SnackBarAction(
                                        label: 'UNDO',
                                        textColor: DesignSystem.primary,
                                        onPressed: () => ref.read(tabsProvider.notifier).undoCloseTab(),
                                      ),
                                    ),
                                  );
                                },
                                scaleFactor: 0.8,
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: DesignSystem.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: HoverScaleWidget(
              onTap: () => ref.read(tabsProvider.notifier).addTab(),
              scaleFactor: 0.9,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: DesignSystem.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
