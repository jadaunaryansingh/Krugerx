import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/tabs_provider.dart';

class SearchCommandBar extends ConsumerStatefulWidget {
  const SearchCommandBar({super.key});

  @override
  ConsumerState<SearchCommandBar> createState() => _SearchCommandBarState();
}

class _SearchCommandBarState extends ConsumerState<SearchCommandBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      constraints: const BoxConstraints(maxWidth: 680),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: _isFocused ? 0.35 : 0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _isFocused 
              ? Colors.white.withValues(alpha: 0.5) 
              : Colors.white.withValues(alpha: 0.15), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: _isFocused ? 32 : 24,
            spreadRadius: _isFocused ? 4 : 0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: TextField(
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                final query = value.trim();
                final tabsState = ref.read(tabsProvider);
                
                // If it looks like a URL, go to it. Otherwise, use native search.
                if (Uri.tryParse(query)?.hasScheme == true || query.contains('.') && !query.contains(' ')) {
                  String finalUrl = query;
                  if (!finalUrl.startsWith('http')) {
                    finalUrl = 'https://$finalUrl';
                  }
                  ref.read(tabsProvider.notifier).updateTabUrl(tabsState.activeIndex, finalUrl);
                } else {
                  ref.read(tabsProvider.notifier).updateTabUrl(tabsState.activeIndex, 'kruger://search?q=${Uri.encodeComponent(query)}');
                }
              }
            },
            decoration: InputDecoration(
              hintText: 'Search the web or type a command...',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 12.0),
                child: Icon(
                  Icons.search, 
                  color: _isFocused ? Colors.white : Colors.white54, 
                  size: 24,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner, 
                      color: Colors.white.withValues(alpha: 0.4), 
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Text(
                        '⌘ K',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
        ),
      ),
    );
  }
}

