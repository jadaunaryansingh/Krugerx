import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/providers/tabs_provider.dart';

class SourceCodeWidget extends ConsumerStatefulWidget {
  final String sourceTabId;

  const SourceCodeWidget({super.key, required this.sourceTabId});

  @override
  ConsumerState<SourceCodeWidget> createState() => _SourceCodeWidgetState();
}

class _SourceCodeWidgetState extends ConsumerState<SourceCodeWidget> {
  String _source = 'Loading source code...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSource();
  }

  Future<void> _fetchSource() async {
    final controller = webViewControllers[widget.sourceTabId];
    if (controller != null) {
      try {
        final result = await controller.runJavaScriptReturningResult('document.documentElement.outerHTML');
        if (mounted) {
          setState(() {
            // JS strings returned might be enclosed in quotes and escaped
            _source = result.toString();
            // Basic unescaping if it's a JSON string representation
            if (_source.startsWith('"') && _source.endsWith('"')) {
              _source = _source.substring(1, _source.length - 1)
                  .replaceAll('\\n', '\n')
                  .replaceAll('\\"', '"')
                  .replaceAll('\\\'', "'")
                  .replaceAll('\\\\', '\\');
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _source = 'Failed to load source: $e';
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _source = 'Tab not found.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignSystem.surface,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: DesignSystem.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                _source,
                style: DesignSystem.dataMono.copyWith(
                  fontSize: 12,
                  color: DesignSystem.onSurface,
                ),
              ),
            ),
    );
  }
}
