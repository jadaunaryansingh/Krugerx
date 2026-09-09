import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/widgets/hover_scale_widget.dart';
import '../../browser/browser_screen.dart';

class AiSidebar extends ConsumerStatefulWidget {
  const AiSidebar({super.key});

  @override
  ConsumerState<AiSidebar> createState() => _AiSidebarState();
}

class _AiSidebarState extends ConsumerState<AiSidebar> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(aiProvider.notifier).sendMessage(text);
      _controller.clear();
      // Auto-scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    final messages = aiState.activeMessages;

    return Column(
      children: [
        // Header
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: const Color(0xFF111111),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF222222))),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, size: 14, color: DesignSystem.primary),
              const SizedBox(width: 8),
              Text(
                'AI Core Assistant'.toUpperCase(),
                style: DesignSystem.dataMono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.primary,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              HoverScaleWidget(
                scaleFactor: 0.8,
                onTap: () => ref.read(aiSidebarVisibleProvider.notifier).hide(),
                child: const Icon(Icons.close, size: 14, color: DesignSystem.onSurfaceVariant),
              ),
            ],
          ),
        ),

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0A0A),
            border: Border(bottom: BorderSide(color: Color(0xFF222222))),
          ),
          child: Row(
            children: [
              _actionButton('[OPTIMIZE]', () {}),
              const SizedBox(width: 8),
              _actionButton('[REBOOT]', () {}),
              const SizedBox(width: 8),
              _actionButton('[SCAN]', () {}),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Container(
            color: const Color(0xFF050505),
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.role == 'user';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? '[USER]' : '[AI]',
                              style: DesignSystem.dataMono.copyWith(
                                fontSize: 10,
                                color: isUser ? DesignSystem.primary : DesignSystem.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                msg.content,
                                style: DesignSystem.dataMono.copyWith(
                                  fontSize: 10,
                                  color: isUser ? Colors.white : const Color(0xFFAAAAAA),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            border: Border(top: BorderSide(color: Color(0xFF222222))),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                const Text(
                  '>',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'JetBrains Mono',
                    color: DesignSystem.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter protocol...',
                      hintStyle: TextStyle(color: DesignSystem.onSurfaceVariant),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'JetBrains Mono',
                      color: Colors.white,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return HoverScaleWidget(
      scaleFactor: 0.95,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            fontFamily: 'JetBrains Mono',
            color: DesignSystem.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[SYSTEM] AI Core initialized. Standing by for protocols.',
            style: DesignSystem.dataMono.copyWith(
              fontSize: 10,
              color: DesignSystem.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

