import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../../../theme.dart';

class AiChatPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const AiChatPanel({super.key, required this.onClose});

  @override
  ConsumerState<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends ConsumerState<AiChatPanel> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start default session if none active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(aiProvider).activeSession == null) {
        ref.read(aiProvider.notifier).createSession('openai', 'gpt-4o');
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(aiProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(left: BorderSide(color: colors.surfaceContainerHigh)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.surfaceContainerHigh)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: colors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    aiState.activeSession?.title ?? 'AI Assistant',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: KrugerXTheme.primary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: widget.onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: aiState.activeMessages.length + (aiState.isStreaming ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == aiState.activeMessages.length) {
                  // Streaming message
                  return _ChatBubble(
                    content: aiState.streamingText ?? '...',
                    isUser: false,
                    isStreaming: true,
                  );
                }
                final msg = aiState.activeMessages[i];
                return _ChatBubble(
                  content: msg.content,
                  isUser: msg.role == 'user',
                  isStreaming: false,
                );
              },
            ),
          ),

          // Input area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask AI...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: colors.primary),
                    onPressed: aiState.isStreaming ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isStreaming;

  const _ChatBubble({required this.content, required this.isUser, required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? colors.primary.withValues(alpha: 0.15) : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
          ),
          border: isUser ? Border.all(color: colors.primary.withValues(alpha: 0.3)) : null,
        ),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: TextStyle(color: isUser ? colors.onSurface : colors.onSurfaceVariant)),
            if (isStreaming)
               Padding(
                 padding: const EdgeInsets.only(top: 8),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)),
                   ],
                 ),
               ),
          ],
        ),
      ),
    );
  }
}
