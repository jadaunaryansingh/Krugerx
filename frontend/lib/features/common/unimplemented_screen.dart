import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';

class UnimplementedScreen extends StatelessWidget {
  final String moduleName;

  const UnimplementedScreen({super.key, required this.moduleName});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.warning_amber_rounded, color: DesignSystem.primary, size: 64),
        const SizedBox(height: 24),
        Text(
          'SYS_ERR // 0xDEAD',
          style: DesignSystem.dataMono.copyWith(fontSize: 16, color: DesignSystem.primary, letterSpacing: 3.0),
        ),
        const SizedBox(height: 8),
        Text(
          'MODULE_OFFLINE: $moduleName',
          style: TextStyle(fontFamily: DesignSystem.fontFamilyHanken).copyWith(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            shadows: [Shadow(color: DesignSystem.primary.withValues(alpha: 0.6), blurRadius: 8)],
          ),
        ),
      ],
    );

    if (!MediaQuery.disableAnimationsOf(context)) {
      content = content.animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(child: content),
    );
  }
}
