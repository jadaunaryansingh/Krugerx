import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/tabs_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/hover_scale_widget.dart';
import '../../bookmarks/providers/bookmarks_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/models/history_models.dart';
import 'package:flutter/services.dart';
import '../../history/providers/history_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
// To access webViewControllers

class AddressBarWidget extends ConsumerStatefulWidget {
  const AddressBarWidget({super.key});

  @override
  ConsumerState<AddressBarWidget> createState() => _AddressBarWidgetState();
}

class _AddressBarWidgetState extends ConsumerState<AddressBarWidget> {
  final _urlController = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isFocused = false;
  int _selectedIndex = -1;
  List<LocalHistory> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _urlController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _urlController.text.length,
        );
        _updateSuggestions(_urlController.text);
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
    
    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (_suggestions.isNotEmpty) {
            _selectedIndex = (_selectedIndex + 1) % _suggestions.length;
            if (_overlayEntry != null) _overlayEntry!.markNeedsBuild();
            return KeyEventResult.handled;
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (_suggestions.isNotEmpty) {
            _selectedIndex = _selectedIndex - 1 < 0 ? _suggestions.length - 1 : _selectedIndex - 1;
            if (_overlayEntry != null) _overlayEntry!.markNeedsBuild();
            return KeyEventResult.handled;
          }
        }
      }
      return KeyEventResult.ignored;
    };

    
    _urlController.addListener(() {
      if (_focusNode.hasFocus) {
        _updateSuggestions(_urlController.text);
        if (_suggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _hideOverlay();
        }
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      _suggestions = [];
      _selectedIndex = -1;
      return;
    }
    
    final allHistory = ref.read(historyProvider);
    final q = query.toLowerCase();
    
    final matching = allHistory.where((e) {
      return e.url.toLowerCase().contains(q) || (e.title?.toLowerCase().contains(q) ?? false);
    }).toList();
    
    matching.sort((a, b) => b.visitCount.compareTo(a.visitCount));
    
    _suggestions = matching.take(5).toList();
    _selectedIndex = -1;
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    if (_suggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final disableAnim = MediaQuery.disableAnimationsOf(context);
        
        Widget child = CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 32),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500, // Fixed width or constrain to parent
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF333333)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: StatefulBuilder(
                builder: (context, setStateOverlay) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      final isSelected = index == _selectedIndex;
                      
                      return InkWell(
                        onTap: () {
                          _urlController.text = item.url;
                          _handleNavigate();
                        },
                        onHover: (hovered) {
                          if (hovered) {
                            setStateOverlay(() => _selectedIndex = index);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: isSelected ? DesignSystem.primary.withValues(alpha: 0.1) : Colors.transparent,
                          child: Row(
                            children: [
                              Icon(Icons.history, size: 14, color: isSelected ? DesignSystem.primary : DesignSystem.onSurfaceVariant),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (item.title != null && item.title!.isNotEmpty)
                                      Text(
                                        item.title!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: DesignSystem.dataMono.copyWith(fontSize: 12, color: Colors.white),
                                      ),
                                    Text(
                                      item.url,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: DesignSystem.dataMono.copyWith(fontSize: 10, color: DesignSystem.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
        
        if (!disableAnim) {
          child = child.animate().fade(duration: 150.ms).slideY(begin: -0.1, end: 0, duration: 150.ms, curve: Curves.easeOut);
        }
        
        return Positioned(
          left: 0,
          right: 0, // This makes it stretch to available width, but we need horizontal constraints. Wait, Positioned inside Overlay is full screen.
          child: Center(
            child: child
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleNavigate() {
    final tabsState = ref.read(tabsProvider);
    final activeIndex = tabsState.activeIndex;
    if (activeIndex >= 0) {
      String input = _urlController.text.trim();
      if (_selectedIndex >= 0 && _selectedIndex < _suggestions.length) {
        input = _suggestions[_selectedIndex].url;
      }
      
      if (input.isNotEmpty) {
        String url = input;
        
        final isLikelyUrl = (input.contains('.') && !input.contains(' ')) || 
                            input.startsWith('http://') || 
                            input.startsWith('https://') ||
                            input.startsWith('kruger://') ||
                            input.startsWith('localhost:');

        if (!isLikelyUrl) {
          url = 'kruger://search?q=${Uri.encodeComponent(input)}';
        } else if (!input.startsWith('http://') && !input.startsWith('https://') && !input.startsWith('kruger://')) {
          url = 'https://$input';
        }

        ref.read(tabsProvider.notifier).updateTabUrl(activeIndex, url);
        _focusNode.unfocus();
        _hideOverlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabsState = ref.watch(tabsProvider);
    final activeTab = tabsState.activeTab;

    // Update text field if it doesn't have focus and URL changed
    if (!_focusNode.hasFocus && activeTab != null && _urlController.text != activeTab.url) {
      _urlController.text = activeTab.url;
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          // Nav Controls
          Row(
            children: [
              AnimatedIconButton(icon: Icons.arrow_back, tooltip: 'Back', onPressed: () async {
                if (activeTab != null) {
                  final controller = webViewControllers[activeTab.id];
                  if (controller != null && await controller.canGoBack()) {
                    controller.goBack();
                  }
                }
              }),
              AnimatedIconButton(icon: Icons.arrow_forward, tooltip: 'Forward', opacity: 0.5, onPressed: () async {
                if (activeTab != null) {
                  final controller = webViewControllers[activeTab.id];
                  if (controller != null && await controller.canGoForward()) {
                    controller.goForward();
                  }
                }
              }),
              AnimatedIconButton(icon: Icons.refresh, tooltip: 'Refresh', onPressed: () {
                if (activeTab != null) {
                  final controller = webViewControllers[activeTab.id];
                  if (controller != null) {
                    controller.reload();
                  } else {
                    ref.read(tabsProvider.notifier).updateTabUrl(tabsState.activeIndex, activeTab.url);
                  }
                }
              }),
              AnimatedIconButton(icon: Icons.home_outlined, tooltip: 'Home', onPressed: () {
                if (tabsState.activeIndex >= 0) {
                  ref.read(tabsProvider.notifier).updateTabUrl(tabsState.activeIndex, 'kruger://newtab');
                }
              }),
            ],
          ),
          const SizedBox(width: 16),
          // Address Bar
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isFocused ? DesignSystem.primary.withValues(alpha: 0.5) : const Color(0xFF333333),
                  width: 1,
                ),
                boxShadow: _isFocused
                    ? [BoxShadow(color: DesignSystem.primary.withValues(alpha: 0.15), blurRadius: 10, )]
                    : [const BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2), )],
              ),
              child: Row(
                children: [
                  Tooltip(
                    message: 'Search',
                    child: HoverScaleWidget(
                      scaleFactor: 0.9,
                      onTap: () {
                        context.push('/search');
                      },
                      child: Icon(Icons.search, size: 14, color: DesignSystem.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Secure Connection',
                    child: HoverScaleWidget(
                      scaleFactor: 0.9,
                      onTap: () {
                        context.push('/lock');
                      },
                      child: Icon(Icons.lock, size: 14, color: DesignSystem.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: TextField(
                        controller: _urlController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 14),
                          isDense: true,
                        ),
                        style: DesignSystem.dataMono.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w500,
                        ),
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => _handleNavigate(),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Reader Mode',
                    child: HoverScaleWidget(
                      scaleFactor: 0.9,
                      onTap: () {
                        if (activeTab != null && activeTab.url.isNotEmpty && activeTab.url != 'kruger://newtab') {
                          final tabsState = ref.read(tabsProvider);
                          final index = tabsState.tabs.indexWhere((t) => t.id == activeTab.id);
                          if (index != -1) {
                            ref.read(tabsProvider.notifier).toggleReaderMode(index);
                          }
                        }
                      },
                      child: Icon(
                        Icons.article, 
                        size: 14, 
                        color: (activeTab?.isReaderMode ?? false) ? DesignSystem.primary : DesignSystem.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Bookmark this page',
                    child: HoverScaleWidget(
                      scaleFactor: 0.9,
                      onTap: () {
                        if (activeTab != null && activeTab.url.isNotEmpty && activeTab.url != 'kruger://newtab') {
                          ref.read(bookmarksProvider.notifier).addBookmark(
                            activeTab.title.isEmpty ? 'New Bookmark' : activeTab.title,
                            activeTab.url,
                          );
                        }
                      },
                      child: Icon(Icons.star_border, size: 14, color: DesignSystem.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right: Profile avatar + hamburger menu
          Row(
            children: [
              // Profile avatar (quick access to profile page)
              Tooltip(
                message: 'Profile',
                child: HoverScaleWidget(
                  scaleFactor: 0.9,
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DesignSystem.primary.withValues(alpha: 0.1),
                      border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.person, size: 16, color: DesignSystem.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Hamburger menu
              Theme(
                data: Theme.of(context).copyWith(hoverColor: const Color(0xFF2A2A2A)),
                child: PopupMenuButton<String>(
                  tooltip: 'Menu',
                  color: const Color(0xFF181818),
                  elevation: 12,
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.2)),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'new_tab':
                        ref.read(tabsProvider.notifier).addTab();
                      case 'history':
                        context.push('/history');
                      case 'bookmarks':
                        context.push('/bookmarks');
                      case 'downloads':
                        context.push('/downloads');
                      case 'delete_data':
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF181818),
                            title: Text('Delete Browsing Data', style: DesignSystem.dataMono.copyWith(color: DesignSystem.primary)),
                            content: Text('Clear history and session data?', style: DesignSystem.bodyMd),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                              TextButton(
                                onPressed: () {
                                  ref.read(historyProvider.notifier).clearAll();
                                  Navigator.pop(context);
                                },
                                child: Text('CLEAR', style: TextStyle(color: DesignSystem.primary)),
                              ),
                            ],
                          ),
                        );
                      case 'zoom_in':
                        if (activeTab != null) {
                          final idx = tabsState.tabs.indexWhere((t) => t.id == activeTab.id);
                          if (idx != -1) {
                            final newZoom = (tabsState.tabs[idx].zoomScale + 0.1).clamp(0.5, 3.0);
                            ref.read(tabsProvider.notifier).updateTabZoomScale(idx, newZoom);
                            webViewControllers[activeTab.id]?.runJavaScript("document.body.style.zoom='$newZoom'");
                          }
                        }
                      case 'zoom_out':
                        if (activeTab != null) {
                          final idx = tabsState.tabs.indexWhere((t) => t.id == activeTab.id);
                          if (idx != -1) {
                            final newZoom = (tabsState.tabs[idx].zoomScale - 0.1).clamp(0.5, 3.0);
                            ref.read(tabsProvider.notifier).updateTabZoomScale(idx, newZoom);
                            webViewControllers[activeTab.id]?.runJavaScript("document.body.style.zoom='$newZoom'");
                          }
                        }
                      case 'find_in_page':
                        ref.read(tabsProvider.notifier).toggleFindBar();
                      case 'view_source':
                        if (activeTab != null) {
                          ref.read(tabsProvider.notifier).addTab(
                            url: 'kruger://source?id=${activeTab.id}',
                            title: 'Source: ${activeTab.title.isEmpty ? activeTab.url : activeTab.title}',
                          );
                        }
                      case 'settings':
                        context.push('/settings');
                      case 'logout':
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                    }
                  },
                  itemBuilder: (context) {
                    final zoom = activeTab != null
                        ? (tabsState.tabs.firstWhere((t) => t.id == activeTab.id, orElse: () => tabsState.tabs.first).zoomScale * 100).round()
                        : 100;
                    final mono = DesignSystem.dataMono;
                    Widget item(IconData icon, String label, {String? shortcut, Color? color}) {
                      return Row(children: [
                        Icon(icon, size: 15, color: color ?? DesignSystem.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(child: Text(label, style: mono.copyWith(fontSize: 12, color: color ?? DesignSystem.onSurface))),
                        if (shortcut != null) Text(shortcut, style: mono.copyWith(fontSize: 11, color: const Color(0xFF666666))),
                      ]);
                    }
                    return [
                      PopupMenuItem(value: 'new_tab',      child: item(Icons.add,                    'New Tab',               shortcut: 'Ctrl+T')),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'history',      child: item(Icons.history,                'History',               shortcut: 'Ctrl+H')),
                      PopupMenuItem(value: 'bookmarks',    child: item(Icons.bookmarks_outlined,     'Bookmarks',             shortcut: 'Ctrl+D')),
                      PopupMenuItem(value: 'downloads',    child: item(Icons.download_outlined,      'Downloads',             shortcut: 'Ctrl+J')),
                      PopupMenuItem(value: 'delete_data',  child: item(Icons.delete_outline,         'Delete Browsing Data…', shortcut: 'Ctrl+⇧+Del')),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        enabled: false,
                        child: Row(children: [
                          Icon(Icons.zoom_in, size: 15, color: DesignSystem.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text('Zoom', style: mono.copyWith(fontSize: 12, color: DesignSystem.onSurface)),
                          const Spacer(),
                          _ZoomControl(
                            zoom: zoom,
                            onZoomOut: () { Navigator.pop(context); },
                            onZoomIn:  () { Navigator.pop(context); },
                            tabId: activeTab?.id,
                            tabIndex: activeTab != null ? tabsState.tabs.indexWhere((t) => t.id == activeTab.id) : -1,
                          ),
                        ]),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'find_in_page', child: item(Icons.search,                'Find in Page',          shortcut: 'Ctrl+F')),
                      PopupMenuItem(value: 'view_source',  child: item(Icons.code,                  'View Source')),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'settings',     child: item(Icons.settings_outlined,     'Settings')),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'logout',       child: item(Icons.logout,                'Logout',               color: DesignSystem.primary)),
                    ];
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.menu, size: 16, color: DesignSystem.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class AnimatedIconButton extends StatefulWidget {
  final IconData? icon;
  final String? text;
  final VoidCallback onPressed;
  final double opacity;
  final String tooltip;
  final bool isPrimary;

  const AnimatedIconButton({
    super.key,
    this.icon,
    this.text,
    required this.onPressed,
    required this.tooltip,
    this.opacity = 1.0,
    this.isPrimary = false,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.text != null) {
      child = Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
          color: widget.isPrimary ? const Color(0xFF2A2A2A) : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text!,
          style: DesignSystem.dataMono.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: DesignSystem.primary),
        ),
      );
    } else {
      child = Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isPrimary ? const Color(0xFF2A2A2A) : Colors.transparent,
          border: widget.isPrimary ? Border.all(color: DesignSystem.primary) : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Icon(widget.icon, size: 16, color: widget.isPrimary ? DesignSystem.primary : DesignSystem.onSurfaceVariant),
      );
    }

    final disableAnim = MediaQuery.disableAnimationsOf(context);
    
    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: widget.tooltip,
          child: Opacity(
            opacity: widget.opacity,
            child: disableAnim 
              ? child 
              : child.animate(target: (_isHovered || _isPressed) ? 1 : 0)
                  .scaleXY(end: _isPressed ? 0.9 : 1.15, duration: 150.ms, curve: Curves.easeOut)
                  .tint(color: Colors.white.withValues(alpha: 0.1), end: 0.5),
          ),
        ),
      ),
    );

    return button;
  }
}

/// Inline zoom control used inside the hamburger menu.
class _ZoomControl extends ConsumerWidget {
  final int zoom;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final String? tabId;
  final int tabIndex;

  const _ZoomControl({
    required this.zoom,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.tabId,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void adjustZoom(double delta) {
      if (tabIndex < 0 || tabId == null) return;
      final tabsState = ref.read(tabsProvider);
      final current = tabsState.tabs[tabIndex].zoomScale;
      final next = (current + delta).clamp(0.5, 3.0);
      ref.read(tabsProvider.notifier).updateTabZoomScale(tabIndex, next);
      webViewControllers[tabId]?.runJavaScript("document.body.style.zoom='$next'");
    }

    return Row(children: [
      _SmallBtn(icon: Icons.remove, onTap: () { adjustZoom(-0.1); onZoomOut(); }),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text('$zoom%', style: DesignSystem.dataMono.copyWith(fontSize: 11, color: DesignSystem.onSurface)),
      ),
      _SmallBtn(icon: Icons.add, onTap: () { adjustZoom(0.1); onZoomIn(); }),
    ]);
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 13, color: DesignSystem.onSurface),
        ),
      ),
    );
  }
}

