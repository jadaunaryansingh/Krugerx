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
          url = 'https://duckduckgo.com/?q=${Uri.encodeComponent(input)}';
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
                            activeTab.title ?? 'New Bookmark', 
                            activeTab.url
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
          const SizedBox(width: 16),
          // Right Icons
          Row(
            children: [
              AnimatedIconButton(text: "INT", tooltip: "History", onPressed: () {
                context.push('/history');
              }),
              const SizedBox(width: 8),
              AnimatedIconButton(icon: Icons.data_object, tooltip: "Downloads", isPrimary: true, onPressed: () {
                context.push('/downloads');
              }),
              const SizedBox(width: 8),
              Theme(
                data: Theme.of(context).copyWith(
                  hoverColor: const Color(0xFF2A2A2A),
                ),
                child: PopupMenuButton<String>(
                  tooltip: 'Profile & Settings',
                  color: const Color(0xFF1A1A1A),
                  elevation: 8,
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF333333)),
                  ),
                  onSelected: (value) {
                    if (value == 'find_in_page') {
                      ref.read(tabsProvider.notifier).toggleFindBar();
                    } else if (value == 'view_source') {
                      if (activeTab != null) {
                        ref.read(tabsProvider.notifier).addTab(url: 'kruger://source?id=${activeTab!.id}', title: 'Source: ${activeTab!.title ?? activeTab!.url}');
                      }
                    } else if (value == 'settings') {
                      context.push('/settings');
                    } else if (value == 'logout') {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'find_in_page',
                      child: Row(
                        children: [
                          const Icon(Icons.search_outlined, size: 16, color: DesignSystem.onSurface),
                          const SizedBox(width: 12),
                          Text('Find in Page', style: DesignSystem.dataMono.copyWith(fontSize: 12, color: DesignSystem.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'view_source',
                      child: Row(
                        children: [
                          const Icon(Icons.code, size: 16, color: DesignSystem.onSurface),
                          const SizedBox(width: 12),
                          Text('View Source', style: DesignSystem.dataMono.copyWith(fontSize: 12, color: DesignSystem.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          const Icon(Icons.settings_outlined, size: 16, color: DesignSystem.onSurface),
                          const SizedBox(width: 12),
                          Text('Settings', style: DesignSystem.dataMono.copyWith(fontSize: 12, color: DesignSystem.onSurface)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: DesignSystem.primary),
                          const SizedBox(width: 12),
                          Text('Logout', style: DesignSystem.dataMono.copyWith(fontSize: 12, color: DesignSystem.primary)),
                        ],
                      ),
                    ),
                  ],
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

