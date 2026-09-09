import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/browser_provider.dart';
import '../../../core/theme/design_system.dart';
import '../browser_screen.dart';

class BrowserSidebar extends ConsumerWidget {
  const BrowserSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(browserProvider);
    final activeTab = state.activeTab;
    final isIncognito = activeTab.isIncognito;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 64,
          decoration: BoxDecoration(
            color: isIncognito
                ? DesignSystem.incognitoColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.2), // Glassmorphic translucent background
            border: Border(
              right: BorderSide(
                color: isIncognito
                    ? DesignSystem.incognitoColor.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1), // Subtle border
                width: 1.0,
              ),
            ),
          ),
          child: Column(
        children: [
          const SizedBox(height: 12),
          // KrugerX Logo Mark
          ShaderMask(
            shaderCallback: (bounds) => DesignSystem.brandBrassGradient.createShader(bounds),
            child: const Text(
              'KX',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Navigation Actions
          _SidebarBtn(
            icon: Icons.public_rounded,
            tooltip: 'Browser',
            isActive: true,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SidebarBtn(
            icon: Icons.auto_awesome_rounded,
            tooltip: 'AI Assistant',
            isActive: ref.watch(aiSidebarVisibleProvider),
            onTap: () {
              ref.read(aiSidebarVisibleProvider.notifier).toggle();
            },
          ),
          const SizedBox(height: 8),
          _SidebarBtn(
            icon: Icons.bookmarks_outlined,
            tooltip: 'Bookmarks',
            isActive: false,
            onTap: () => context.push('/bookmarks'),
          ),
          const SizedBox(height: 8),
          _SidebarBtn(
            icon: Icons.history_rounded,
            tooltip: 'History',
            isActive: false,
            onTap: () => context.push('/history'),
          ),
          
          const Spacer(),
          
          // Bottom Actions
          _SidebarBtn(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            isActive: false,
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
    ),
    );
  }
}

class _SidebarBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarBtn({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_SidebarBtn> createState() => _SidebarBtnState();
}

class _SidebarBtnState extends State<_SidebarBtn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? DesignSystem.brandGold.withValues(alpha: 0.15)
                  : (_hovering ? colors.surfaceContainerHigh : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isActive
                    ? DesignSystem.brandGold.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.isActive
                  ? DesignSystem.brandGold
                  : (_hovering ? colors.onSurface : colors.onSurfaceVariant),
            ),
          ).animate(target: _hovering ? 1 : 0).scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }
}

