import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme.dart';

/// Reader mode overlay — displays extracted article text in a clean, readable layout.
class ReaderModeView extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onClose;

  const ReaderModeView({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: const Color(0xFF141210), // warm dark paper
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: KrugerXTheme.primary.withValues(alpha: 0.2), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.chrome_reader_mode_rounded, size: 18, color: KrugerXTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Reader Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KrugerXTheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: colors.onSurfaceVariant),
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE8E0D0), // warm parchment white
                          height: 1.3,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: KrugerXTheme.brassGradient,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      content.isNotEmpty ? content : 'Could not extract article content from this page.',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFFBEB5A5), // warm reading text
                        height: 1.7,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
