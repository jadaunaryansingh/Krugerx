import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../theme/tokens.dart';

class BrowserBottomBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onHome;
  final VoidCallback onShowAi;
  final VoidCallback onShowTabGrid;
  final int onTabCount;
  final bool isIncognito;
  final bool showAi;
  final bool showTabGrid;

  const BrowserBottomBar({
    super.key,
    required this.onBack,
    required this.onForward,
    required this.onHome,
    required this.onTabCount,
    required this.isIncognito,
    required this.onShowAi,
    required this.showAi,
    required this.onShowTabGrid,
    required this.showTabGrid,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<KrugerColors>()!;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isIncognito
            ? Color.lerp(themeExt.surface1, KrugerXTheme.incognitoColor, 0.15)
            : themeExt.surface1,
        border: Border(
          top: BorderSide(
            color: isIncognito
                ? KrugerXTheme.incognitoColor.withValues(alpha: 0.3)
                : themeExt.gold.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BarBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack, tooltip: 'Back'),
          _BarBtn(icon: Icons.arrow_forward_ios_rounded, onTap: onForward, tooltip: 'Forward'),
          _BarBtn(icon: Icons.home_rounded, onTap: onHome, tooltip: 'Home'),

          Tooltip(
            message: 'Tabs',
            child: GestureDetector(
              onTap: onShowTabGrid,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: showTabGrid
                        ? themeExt.gold
                        : (isIncognito
                            ? KrugerXTheme.incognitoColor.withValues(alpha: 0.6)
                            : themeExt.gold.withValues(alpha: 0.6)),
                    width: showTabGrid ? 2 : 1.5,
                  ),
                  color: showTabGrid
                      ? themeExt.gold.withValues(alpha: 0.15)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  onTabCount > 99 ? '99+' : '\$onTabCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isIncognito ? KrugerXTheme.incognitoColor : themeExt.gold,
                  ),
                ),
              ),
            ),
          ),

          _BarBtn(
            icon: showAi ? Icons.auto_awesome_rounded : Icons.auto_awesome_outlined,
            onTap: onShowAi,
            tooltip: 'AI Assistant',
            activeColor: showAi ? themeExt.gold : null,
          ),
        ],
      ),
    );
  }
}

class _BarBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? activeColor;

  const _BarBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.activeColor,
  });

  @override
  State<_BarBtn> createState() => _BarBtnState();
}

class _BarBtnState extends State<_BarBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KrugerColors>()!;
    final color = widget.activeColor ?? colors.textSecondary;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.transparent, // expanded hit area
            child: Icon(
              widget.icon,
              size: 22,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
