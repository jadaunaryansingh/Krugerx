import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/tabs_provider.dart';
import '../../search/native_search_screen.dart';
import 'find_bar.dart';
import 'source_code_widget.dart';

class BrowserEngineWidget extends ConsumerStatefulWidget {
  final String url;
  final String tabId;
  final bool isMuted;

  const BrowserEngineWidget({
    super.key,
    required this.url,
    required this.tabId,
    this.isMuted = false,
  });

  @override
  ConsumerState<BrowserEngineWidget> createState() => _BrowserEngineWidgetState();
}

class _BrowserEngineWidgetState extends ConsumerState<BrowserEngineWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isCurrentlyReaderMode = false;
  late final String _readerToken;

  @override
  void initState() {
    super.initState();
    _readerToken = Random().nextInt(999999999).toString();
    _controller = WebViewController()
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(DesignSystem.surface)
      ..addJavaScriptChannel(
        'ReaderModeChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'failed:$_readerToken') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reader mode unavailable for this page'),
                  backgroundColor: Color(0xFF272727),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
              // Find the index of this tab and toggle back
              final tabsState = ref.read(tabsProvider);
              final index = tabsState.tabs.indexWhere((t) => t.id == widget.tabId);
              if (index != -1 && tabsState.tabs[index].isReaderMode) {
                ref.read(tabsProvider.notifier).toggleReaderMode(index);
              }
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String loadedUrl) async {
            if (mounted) {
              setState(() => _isLoading = false);
              
              if (widget.isMuted) {
                _controller.runJavaScript('document.querySelectorAll("video, audio").forEach(elem => elem.muted = true);');
              }
              
              // Only sync URL if we didn't inject reader mode content
              if (loadedUrl != widget.url && !_isCurrentlyReaderMode) {
                ref.read(tabsProvider.notifier).updateTabUrlById(widget.tabId, loadedUrl);
              }
              
              final title = await _controller.getTitle();
              if (title != null && title.isNotEmpty) {
                ref.read(tabsProvider.notifier).updateTabTitleById(widget.tabId, title);
              }
              
              final tabsState = ref.read(tabsProvider);
              final index = tabsState.tabs.indexWhere((t) => t.id == widget.tabId);
              if (index != -1) {
                final scale = tabsState.tabs[index].zoomScale;
                if (scale != 1.0) {
                  _controller.runJavaScript("document.body.style.zoom = '$scale'");
                }
              }

              _applyReaderModeIfNeeded();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_formatUrl(widget.url)));
      
    webViewControllers[widget.tabId] = _controller;
  }

  void _applyReaderModeIfNeeded() {
    final tabs = ref.read(tabsProvider).tabs;
    final tab = tabs.where((t) => t.id == widget.tabId).firstOrNull;
    if (tab == null || !mounted) return;

    if (tab.isReaderMode && !_isCurrentlyReaderMode) {
      _isCurrentlyReaderMode = true;
      _controller.runJavaScript('''
        (function() {
          try {
            var script = document.createElement('script');
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/readability/0.5.0/Readability.js';
            script.onload = function() {
              try {
                var article = new Readability(document.cloneNode(true)).parse();
                if (article) {
                  document.body.innerHTML = '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px; font-family: monospace; color: #e0e0e0; font-size: 16px; line-height: 1.6;">' + 
                    '<h1 style="color: #ff3333; font-size: 24px; margin-bottom: 24px;">' + article.title + '</h1>' + 
                    article.content + '</div>';
                  document.body.style.backgroundColor = '#050505';
                  // Remove all other stylesheets to prevent interference
                  document.querySelectorAll('link[rel="stylesheet"], style').forEach(function(el) {
                    el.remove();
                  });
                } else {
                  ReaderModeChannel.postMessage('failed:$_readerToken');
                }
              } catch(e) {
                ReaderModeChannel.postMessage('failed:$_readerToken');
              }
            };
            script.onerror = function() {
              ReaderModeChannel.postMessage('failed:$_readerToken');
            };
            document.head.appendChild(script);
          } catch(e) {
            ReaderModeChannel.postMessage('failed:$_readerToken');
          }
        })();
      ''');
    } else if (!tab.isReaderMode && _isCurrentlyReaderMode) {
      _isCurrentlyReaderMode = false;
      _controller.reload(); // Reload to restore original content
    }
  }

  @override
  void dispose() {
    webViewControllers.remove(widget.tabId);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BrowserEngineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _isCurrentlyReaderMode = false;
      _controller.loadRequest(Uri.parse(_formatUrl(widget.url)));
    }
    
    // Check for reader mode changes
    final tab = ref.read(tabsProvider).tabs.where((t) => t.id == widget.tabId).firstOrNull;
    if (tab != null && tab.isReaderMode != _isCurrentlyReaderMode && !_isLoading) {
      _applyReaderModeIfNeeded();
    }

    if (oldWidget.isMuted != widget.isMuted) {
      if (widget.isMuted) {
        _controller.runJavaScript('document.querySelectorAll("video, audio").forEach(elem => elem.muted = true);');
      } else {
        _controller.runJavaScript('document.querySelectorAll("video, audio").forEach(elem => elem.muted = false);');
      }
    }
  }

  String _formatUrl(String input) {
    if (input.isEmpty) return 'about:blank';
    if (input.startsWith('http://') || input.startsWith('https://') || input.startsWith('kruger://') || input.startsWith('file://')) {
      return input;
    }
    
    if (!input.contains(' ') && input.contains('.')) {
      return 'https://$input';
    }
    
    final encodedQuery = Uri.encodeComponent(input);
    return 'https://www.google.com/search?q=$encodedQuery';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.startsWith('kruger://search')) {
      final uri = Uri.parse(widget.url);
      final query = uri.queryParameters['q'] ?? '';
      return NativeSearchScreen(query: query);
    }
    
    if (widget.url.startsWith('kruger://source')) {
      final uri = Uri.parse(widget.url);
      final id = uri.queryParameters['id'] ?? '';
      return SourceCodeWidget(sourceTabId: id);
    }

    final tabsState = ref.watch(tabsProvider);
    
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: DesignSystem.primary,
              minHeight: 2,
            ),
          ),
        if (tabsState.showFindBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FindBar(
              controller: _controller,
              onClose: () => ref.read(tabsProvider.notifier).closeFindBar(),
            ),
          ),
      ],
    );
  }
}
