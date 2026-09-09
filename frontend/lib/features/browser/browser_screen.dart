import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/tabs_provider.dart';
import '../../../core/theme/design_system.dart';
import 'widgets/tab_bar_widget.dart';
import 'widgets/address_bar_widget.dart';
import '../ai/widgets/ai_sidebar.dart';
import 'widgets/browser_engine_widget.dart';
import 'new_tab_page.dart';

import 'providers/telemetry_provider.dart';
import 'package:go_router/go_router.dart';

class AiSidebarVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default to false (no auto-open)

  void toggle() => state = !state;
  void show() => state = true;
  void hide() => state = false;
}

final aiSidebarVisibleProvider = NotifierProvider<AiSidebarVisibleNotifier, bool>(AiSidebarVisibleNotifier.new);

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    if (state.extra is Map<String, dynamic>) {
      final extra = state.extra as Map<String, dynamic>;
      if (extra['url'] != null && extra['consumed'] == false) {
        extra['consumed'] = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(tabsProvider.notifier).addTab(
            url: extra['url'] as String,
            title: extra['title'] as String? ?? extra['url'] as String,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabsState = ref.watch(tabsProvider);
    final activeTab = tabsState.activeTab;
    final isAiVisible = ref.watch(aiSidebarVisibleProvider);
    final telemetry = ref.watch(telemetryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // Background scanline & markers
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewportMarkersPainter(),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Telemetry
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UPTIME: ${telemetry.uptime}', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.primary.withValues(alpha: 0.6))),
                          Text('MEM: ${telemetry.memory}', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.onSurface)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('LAT: ${telemetry.latency.toStringAsFixed(0)}ms', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.primary.withValues(alpha: 0.6))),
                          Text('PKG_LOSS: ${telemetry.packetLoss.toStringAsFixed(2)}%', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.onSurface)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Browser Chrome
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF222222), width: 1)),
                  ),
                  child: Column(
                    children: [
                      const TabBarWidget(),
                      const AddressBarWidget(),
                    ],
                  ),
                ),

                // Main Area
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFF0A0A0A),
                          child: tabsState.tabs.isEmpty
                              ? Center(child: Text('No tabs', style: DesignSystem.bodyLg))
                              : Stack(
                                  children: [
                                    ...tabsState.tabs.map((tab) {
                                      final isActive = tab.id == activeTab?.id;
                                      final isNewTab = tab.url.isEmpty || tab.url == 'about:blank' || tab.url == 'kruger://newtab';
                                      
                                      // NewTabPage is pure Flutter — Offstage works fine.
                                      if (isNewTab) {
                                        return Offstage(
                                          offstage: !isActive,
                                          child: const NewTabPage(),
                                        );
                                      }
                                      
                                      // Real URLs use WebView2 (native control). Inactive tabs must be
                                      // constrained to 1×1 — Offstage doesn't prevent WebView2 from
                                      // painting in the native layer on Windows.
                                      if (isActive) {
                                        return BrowserEngineWidget(
                                          key: ValueKey(tab.id),
                                          url: tab.url,
                                          tabId: tab.id,
                                          isMuted: tab.isMuted,
                                        );
                                      }
                                      return SizedBox(
                                        width: 1,
                                        height: 1,
                                        child: ClipRect(
                                          child: OverflowBox(
                                            maxWidth: 1,
                                            maxHeight: 1,
                                            child: BrowserEngineWidget(
                                              key: ValueKey(tab.id),
                                              url: tab.url,
                                              tabId: tab.id,
                                              isMuted: tab.isMuted,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    // Zombie webviews — constrained to 1×1 so the WebView2
                                    // native control can't paint over the active tab on Windows.
                                    // OverflowBox clips the platform view; state is preserved.
                                    ...ref.watch(tabsProvider.notifier).closedTabs.map((tab) {
                                      if (tab.url.isEmpty || tab.url == 'about:blank' || tab.url == 'kruger://newtab') {
                                        return const SizedBox.shrink();
                                      }
                                      return SizedBox(
                                        width: 1,
                                        height: 1,
                                        child: ClipRect(
                                          child: OverflowBox(
                                            maxWidth: 1,
                                            maxHeight: 1,
                                            child: BrowserEngineWidget(
                                              key: ValueKey(tab.id),
                                              url: tab.url,
                                              tabId: tab.id,
                                              isMuted: true,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                        ),
                      ),
                      if (isAiVisible)
                        Container(
                          width: 320,
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF222222), width: 1)),
                            color: Color(0xFF0A0A0A),
                            boxShadow: [
                              BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(-10, 0)),
                            ],
                          ),
                          child: const AiSidebar(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAiVisible
          ? null
          : FloatingActionButton.small(
              onPressed: () => ref.read(aiSidebarVisibleProvider.notifier).show(),
              backgroundColor: DesignSystem.primaryContainer,
              foregroundColor: DesignSystem.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusDefault),
                side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.psychology, size: 20),
            ),
    );
  }
}

class _ViewportMarkersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DesignSystem.primary.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final crosshairPaint = Paint()
      ..color = DesignSystem.primary.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double bracketLen = 24.0;
    
    // Top Left Bracket
    canvas.drawLine(const Offset(16, 80), const Offset(16 + bracketLen, 80), paint);
    canvas.drawLine(const Offset(16, 80), const Offset(16, 80 + bracketLen), paint);
    
    // Top Right Bracket
    canvas.drawLine(Offset(size.width - 16, 80), Offset(size.width - 16 - bracketLen, 80), paint);
    canvas.drawLine(Offset(size.width - 16, 80), Offset(size.width - 16, 80 + bracketLen), paint);
    
    // Bottom Left Bracket
    canvas.drawLine(Offset(16, size.height - 16), Offset(16 + bracketLen, size.height - 16), paint);
    canvas.drawLine(Offset(16, size.height - 16), Offset(16, size.height - 16 - bracketLen), paint);
    
    // Bottom Right Bracket
    canvas.drawLine(Offset(size.width - 16, size.height - 16), Offset(size.width - 16 - bracketLen, size.height - 16), paint);
    canvas.drawLine(Offset(size.width - 16, size.height - 16), Offset(size.width - 16, size.height - 16 - bracketLen), paint);

    // Crosshairs
    _drawCrosshair(canvas, Offset(size.width / 2, 80), crosshairPaint);
    _drawCrosshair(canvas, Offset(size.width / 2, size.height - 16), crosshairPaint);
    _drawCrosshair(canvas, Offset(16, size.height / 2), crosshairPaint);
    _drawCrosshair(canvas, Offset(size.width - 16, size.height / 2), crosshairPaint);
  }

  void _drawCrosshair(Canvas canvas, Offset center, Paint paint) {
    canvas.drawLine(Offset(center.dx - 10, center.dy), Offset(center.dx + 10, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
