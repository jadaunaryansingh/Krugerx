import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/new_tab_providers.dart';

class SpeedDialRow extends ConsumerWidget {
  const SpeedDialRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speedDials = ref.watch(speedDialProvider);

    return Wrap(
      spacing: 32,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: speedDials.map((item) {
        return SpeedDialCard(
          label: item.label,
          iconUrl: item.iconUrl,
          onTap: () {
            // Handle navigation
          },
        );
      }).toList(),
    );
  }
}

class SpeedDialCard extends StatefulWidget {
  final String label;
  final String iconUrl;
  final VoidCallback onTap;

  const SpeedDialCard({
    super.key,
    required this.label,
    required this.iconUrl,
    required this.onTap,
  });

  @override
  State<SpeedDialCard> createState() => _SpeedDialCardState();
}

class _SpeedDialCardState extends State<SpeedDialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -6.0 : 0.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: _isHovered ? 0.25 : 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Image.network(
                        widget.iconUrl,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.public,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 72,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: _isHovered ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Text(widget.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

