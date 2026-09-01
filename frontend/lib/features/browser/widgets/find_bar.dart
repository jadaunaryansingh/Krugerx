import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/design_system.dart';

class FindBar extends StatefulWidget {
  final WebViewController controller;
  final VoidCallback onClose;

  const FindBar({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  State<FindBar> createState() => _FindBarState();
}

class _FindBarState extends State<FindBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _search(String q, {bool backwards = false}) async {
    if (q.isEmpty) {
      // Clear selection
      await widget.controller.runJavaScript("window.getSelection().removeAllRanges();");
      return;
    }
    
    final escapedQ = q.replaceAll("'", "\\'");
    await widget.controller.runJavaScript("window.find('$escapedQ', false, $backwards, true, false, false, false);");
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 16, color: DesignSystem.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: (val) => _search(val),
              onSubmitted: (val) => _search(val),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Find in page...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            onPressed: () => _search(_ctrl.text, backwards: true),
            splashRadius: 20,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            onPressed: () => _search(_ctrl.text),
            splashRadius: 20,
          ),
          Container(
            width: 1,
            height: 24,
            color: colors.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onClose,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
