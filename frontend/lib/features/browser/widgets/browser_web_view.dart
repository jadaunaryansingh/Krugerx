import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/features/browser/models/tab_model.dart';
import '../providers/browser_provider.dart';
import '../../downloads/providers/downloads_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../../theme/tokens.dart';

class BrowserWebView extends ConsumerStatefulWidget {
  final TabModel activeTab;
  final PullToRefreshController? pullToRefreshController;
  final Function(InAppWebViewController) onWebViewCreated;
  final Function(double) onProgressChanged;
  final Function() onLoadStart;
  final Function(String?) onLoadStop;
  final Function(String, String) onLongPressLink;
  final Function(String) onLongPressImage;
  
  const BrowserWebView({
    super.key,
    required this.activeTab,
    this.pullToRefreshController,
    required this.onWebViewCreated,
    required this.onProgressChanged,
    required this.onLoadStart,
    required this.onLoadStop,
    required this.onLongPressLink,
    required this.onLongPressImage,
  });

  @override
  ConsumerState<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends ConsumerState<BrowserWebView> {
  late final FindInteractionController findInteractionController;

  @override
  void initState() {
    super.initState();
    findInteractionController = FindInteractionController(
      onFindResultReceived: (controller, activeMatchOrdinal, numberOfMatches, isDoneCounting) {
        if (isDoneCounting) {
          ref.read(browserProvider.notifier).setFindResults(
                numberOfMatches,
                activeMatchOrdinal + 1,
              );
        }
      },
    );
  }

  @override
  void dispose() {
    findInteractionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = widget.activeTab;
    final isIncognito = activeTab.isIncognito;
    final desktopUA = ref.read(browserProvider.notifier).activeDesktopUA;

    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: activeTab.url.isEmpty,
        useShouldOverrideUrlLoading: false,
        supportZoom: true,
        allowsInlineMediaPlayback: true,
        incognito: isIncognito,
        userAgent: activeTab.isDesktopMode ? desktopUA : '',
      ),
      findInteractionController: findInteractionController,
      pullToRefreshController: widget.pullToRefreshController,
      onWebViewCreated: (controller) {
        widget.onWebViewCreated(controller);
        controller.addJavaScriptHandler(
          handlerName: '__kruger_find__',
          callback: (_) {},
        );
      },
      onLoadStart: (controller, url) {
        widget.onLoadStart();
        ref.read(browserProvider.notifier).updateFavicon(null);
      },
      onProgressChanged: (controller, progress) {
        widget.onProgressChanged(progress / 100);
        if (progress == 100) {
          widget.pullToRefreshController?.endRefreshing();
        }
      },
      onLoadStop: (controller, url) async {
        widget.pullToRefreshController?.endRefreshing();
        final urlStr = url?.toString();
        widget.onLoadStop(urlStr);
        
        if (urlStr != null && urlStr != 'about:blank') {
          ref.read(browserProvider.notifier).updateUrl(urlStr);
          final title = await controller.getTitle();
          if (!isIncognito) {
            ref.read(historyProvider.notifier).recordVisit(urlStr, title: title ?? '');
          }
        }
        
        // Re-apply night mode if active
        if (activeTab.isNightMode) {
          await controller.evaluateJavascript(
            source: '''
              document.documentElement.style.filter = 'invert(0.88) hue-rotate(180deg)';
              document.querySelectorAll('img, video, canvas, svg').forEach(function(el) {
                el.style.filter = 'invert(1) hue-rotate(180deg)';
              });
            ''',
          );
        }
      },
      onTitleChanged: (controller, title) {
        if (title != null && title.isNotEmpty && title != 'about:blank') {
          ref.read(browserProvider.notifier).updateTitle(title);
        }
      },
      onUpdateVisitedHistory: (controller, url, isReload) async {
        if (url != null) {
          final origin = '${url.scheme}://${url.host}';
          ref.read(browserProvider.notifier).updateFavicon('$origin/favicon.ico');
        }
      },
      shouldOverrideUrlLoading: (controller, nav) async {
        return NavigationActionPolicy.ALLOW;
      },
      onLongPressHitTestResult: (controller, hitTestResult) async {
        final type = hitTestResult.type;
        final extra = hitTestResult.extra;

        if (type == InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
            type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE) {
          final url = extra ?? '';
          if (url.isNotEmpty) {
            widget.onLongPressLink(url, url);
          }
        } else if (type == InAppWebViewHitTestResultType.IMAGE_TYPE) {
          final url = extra ?? '';
          if (url.isNotEmpty) {
            widget.onLongPressImage(url);
          }
        }
      },
      onDownloadStartRequest: (controller, req) async {
        final url = req.url.toString();
        final filename = url.split('/').last.split('?').first;
        final safeFilename = filename.isNotEmpty ? filename : 'download';
        ref.read(downloadsProvider.notifier).startDownload(url, safeFilename);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.download_rounded, size: 16, color: Theme.of(context).extension<KrugerColors>()!.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Downloading "$safeFilename"', maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            width: 320,
          ),
        );
      },
    );
  }
}
