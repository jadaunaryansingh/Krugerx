import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/providers/system_logger.dart';
import '../../../core/providers/tabs_provider.dart';
import '../../../core/widgets/hover_scale_widget.dart';
import '../../../core/widgets/fade_slide_reveal.dart';
import 'providers/telemetry_provider.dart';
import 'providers/browser_provider.dart';
import '../auth/providers/auth_provider.dart';

class NewTabPage extends ConsumerStatefulWidget {
  const NewTabPage({super.key});

  @override
  ConsumerState<NewTabPage> createState() => _NewTabPageState();
}

class _NewTabPageState extends ConsumerState<NewTabPage> with TickerProviderStateMixin {
  late final AnimationController _scanlineController;
  late final AnimationController _spinController;
  late final AnimationController _radarController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    _spinController.dispose();
    _radarController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryProvider);
    final authState = ref.watch(authProvider);
    final browserState = ref.watch(browserProvider);
    final logs = ref.watch(systemLoggerProvider);
    final isAuthenticated = authState.isAuthenticated;

    return Stack(
      children: [
        // Grid background
        Positioned.fill(
          child: CustomPaint(painter: _GridBackgroundPainter()),
        ),

        // Main content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 24, left: 32, right: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildQuickAccess(),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 900) {
                        return ListView(
                          children: [
                            _buildSystemChronometer(telemetry, isAuthenticated),
                            _buildCentralOverride(telemetry),
                            const SizedBox(height: 16),
                            _buildBrowserStatusGrid(telemetry, browserState),
                            const SizedBox(height: 16),
                            SizedBox(height: 300, child: _buildTerminalFeed(logs)),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildSystemChronometer(telemetry, isAuthenticated),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      children: [
                                        Expanded(child: _buildCentralOverride(telemetry)),
                                        const SizedBox(height: 16),
                                        _buildBrowserStatusGrid(telemetry, browserState),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 4,
                                    child: _buildTerminalFeed(logs),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scanline Overlay
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _scanlineController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanlinePainter(_scanlineController.value),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    void doSearch() {
      final q = _searchController.text.trim();
      if (q.isEmpty) return;
      final tabsState = ref.read(tabsProvider);
      ref.read(tabsProvider.notifier).updateTabUrl(
        tabsState.activeIndex,
        'kruger://search?q=${Uri.encodeComponent(q)}',
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(color: DesignSystem.primary.withValues(alpha: 0.12), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(Icons.search, color: DesignSystem.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  style: DesignSystem.dataMono.copyWith(fontSize: 14, color: Colors.white, letterSpacing: 1.0),
                  decoration: InputDecoration(
                    hintText: 'Search or enter address...',
                    hintStyle: DesignSystem.dataMono.copyWith(fontSize: 13, color: Colors.white30),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => doSearch(),
                ),
              ),
              const SizedBox(width: 8),
              HoverScaleWidget(
                scaleFactor: 0.9,
                onTap: doSearch,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: DesignSystem.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.arrow_forward, color: DesignSystem.primary, size: 18),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    final sites = [
      (icon: Icons.code,             label: 'GitHub',    url: 'https://github.com'),
      (icon: Icons.play_circle,      label: 'YouTube',   url: 'https://youtube.com'),
      (icon: Icons.travel_explore,   label: 'Google',    url: 'https://google.com'),
      (icon: Icons.chat_bubble,      label: 'Reddit',    url: 'https://reddit.com'),
      (icon: Icons.auto_stories,     label: 'Wikipedia', url: 'https://wikipedia.org'),
      (icon: Icons.cloud,            label: 'Supabase',  url: 'https://supabase.com'),
    ];

    return Center(
      child: Wrap(
        spacing: 12,
        children: sites.map((s) {
          return HoverScaleWidget(
            scaleFactor: 0.9,
            onTap: () {
              final tabsState = ref.read(tabsProvider);
              ref.read(tabsProvider.notifier).updateTabUrl(tabsState.activeIndex, s.url);
            },
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(s.icon, size: 22, color: DesignSystem.primary),
                  const SizedBox(height: 6),
                  Text(s.label, style: DesignSystem.dataMono.copyWith(fontSize: 10, color: Colors.white60)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: DesignSystem.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: DesignSystem.primary.withValues(alpha: 0.8), blurRadius: 5)],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'CMD_TERM // KRUGX',
              style: TextStyle(fontFamily: DesignSystem.fontFamilyHanken).copyWith(
                fontSize: 20,
                color: DesignSystem.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: [Shadow(color: DesignSystem.primary.withValues(alpha: 0.6), blurRadius: 8)],
              ),
            ),
          ],
        ),
        Row(
          children: [
            _navLink('sys.core_diag', true),
          ],
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Uplink: Stable', style: DesignSystem.dataMono.copyWith(fontSize: 10, letterSpacing: 2.0, color: DesignSystem.primary)),
                Text('0x00A1', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: Colors.white54)),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.terminal, size: 16, color: DesignSystem.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _navLink(String text, bool active) {
    return HoverScaleWidget(
      onTap: () {
        if (!active) {
          final route = '/${text.split('.').last.toLowerCase()}';
          context.push(route);
        }
      },
      scaleFactor: 0.95,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          text.toUpperCase(),
          style: DesignSystem.dataMono.copyWith(
            fontSize: 12,
            color: active ? DesignSystem.primary : DesignSystem.onSurfaceVariant,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 2.0,
            decoration: active ? TextDecoration.underline : TextDecoration.none,
            decorationColor: DesignSystem.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSystemChronometer(TelemetryState telemetry, bool isAuthenticated) {
    return FadeSlideReveal(
      delay: const Duration(milliseconds: 100),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF333333))),
        ),
        padding: const EdgeInsets.only(bottom: 16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SYSTEM CHRONOMETER', style: DesignSystem.dataMono.copyWith(fontSize: 10, letterSpacing: 3.0, color: DesignSystem.primary)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(telemetry.systemTime, style: TextStyle(fontFamily: DesignSystem.fontFamilyHanken).copyWith(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: DesignSystem.primary.withValues(alpha: 0.6), blurRadius: 8)])),
                        const SizedBox(width: 8),
        Text(
          'LOCAL',
          style: TextStyle(fontFamily: DesignSystem.fontFamilyHanken).copyWith(
            fontSize: 10,
            color: DesignSystem.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                _metricPanel('Uptime', telemetry.uptime),
                const SizedBox(width: 16),
                _metricPanel('CPU Cycles', '${telemetry.cpuCycles.toStringAsFixed(2)} GHz'),
                const SizedBox(width: 16),
                HoverScaleWidget(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isAuthenticated ? 'AI SYNC ACTIVE. UPLINK SECURE.' : 'AUTH REQUIRED. AI SYNC LOCKED.')),
                    );
                  },
                  child: _metricPanel('AI Sync', isAuthenticated ? '[SYNCED]' : '[LOCKED]', isPrimary: isAuthenticated),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricPanel(String label, String value, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A).withValues(alpha: 0.9),
        border: Border.all(color: isPrimary ? DesignSystem.primary.withValues(alpha: 0.5) : const Color(0xFF333333)),
        boxShadow: isPrimary ? [BoxShadow(color: DesignSystem.primary.withValues(alpha: 0.15), blurRadius: 10, )] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: DesignSystem.dataMono.copyWith(fontSize: 8, color: isPrimary ? DesignSystem.primary : DesignSystem.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: DesignSystem.dataMono.copyWith(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCentralOverride(TelemetryState telemetry) {
    return FadeSlideReveal(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              DesignSystem.primary.withValues(alpha: 0.05),
              Colors.transparent
            ],
            radius: 0.6,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Labels
            Positioned(
              right: 20, top: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('JITTER: ${telemetry.jitter.toStringAsFixed(2)}ms', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.primary.withValues(alpha: 0.6), letterSpacing: 2.0)),
                  Text('PKT_LOSS: ${telemetry.packetLoss.toStringAsFixed(2)}%', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.primary.withValues(alpha: 0.6), letterSpacing: 2.0)),
                  Container(margin: const EdgeInsets.only(top: 4), width: 64, height: 1, color: DesignSystem.primary.withValues(alpha: 0.3)),
                ],
              ),
            ),
  
            // Orbital Rings & Radar
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _spinController.value * 2 * pi,
                      child: _buildRing(220, BorderStyle.solid, 1, [2, 4]),
                    ),
                    Transform.rotate(
                      angle: -_spinController.value * 2 * pi * 0.6,
                      child: _buildRing(260, BorderStyle.solid, 2, [10, 10]),
                    ),
                    Transform.rotate(
                      angle: _spinController.value * 2 * pi * 0.5,
                      child: _buildRing(300, BorderStyle.solid, 1, [1, 2]),
                    ),
                    Transform.rotate(
                      angle: -_spinController.value * 2 * pi * 1.3,
                      child: _buildRing(140, BorderStyle.solid, 2, [5, 5]),
                    ),
                  ],
                );
              },
            ),
            AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _radarController.value * 2 * pi,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [Colors.transparent, DesignSystem.primary.withValues(alpha: 0.4)],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                );
              }
            ),
  
            // Center Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('FREQ SCAN', style: DesignSystem.dataMono.copyWith(fontSize: 10, color: DesignSystem.primary.withValues(alpha: 0.7), letterSpacing: 3.0)),
                    const SizedBox(width: 4),
                    Text('0x0FE2', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.primary.withValues(alpha: 0.7))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(telemetry.freqScan.toStringAsFixed(1), style: TextStyle(fontFamily: DesignSystem.fontFamilyHanken).copyWith(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: DesignSystem.primary.withValues(alpha: 0.6), blurRadius: 8)])),
                    Text('MHz', style: DesignSystem.dataMono.copyWith(fontSize: 14, color: DesignSystem.primary)),
                  ],
                ),
                Text('STATUS: SYNCED', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.onSurfaceVariant, letterSpacing: 2.0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 4, color: DesignSystem.primary.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Container(width: 16, height: 4, color: DesignSystem.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Container(width: 16, height: 4, color: DesignSystem.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double size, BorderStyle style, double width, List<double> dash) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3), width: width),
      ),
    );
  }

  Widget _buildBrowserStatusGrid(TelemetryState telemetry, BrowserState browserState) {
    final networkHealth = (telemetry.packetLoss > 5.0 || telemetry.jitter > 100) ? 'DEGRADED' : 'STABLE';
    
    return FadeSlideReveal(
      delay: const Duration(milliseconds: 300),
      child: Row(
        children: [
          Expanded(
            child: _metricPanel('Active Tabs', '${browserState.tabs.length}'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _metricPanel('Network Health', networkHealth, isPrimary: networkHealth == 'STABLE'),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalFeed(List<LogEntry> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal, size: 14, color: DesignSystem.primary),
                const SizedBox(width: 8),
                Text('System Log', style: DesignSystem.dataMono.copyWith(fontSize: 10, color: Colors.white, letterSpacing: 2.0)),
                const SizedBox(width: 4),
                Text('TTY1', style: DesignSystem.dataMono.copyWith(fontSize: 8, color: const Color(0xFF444444))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF111111), border: Border.all(color: const Color(0xFF333333))),
              child: Text('Tracking'.toUpperCase(), style: DesignSystem.dataMono.copyWith(fontSize: 8, color: DesignSystem.primary, letterSpacing: 2.0)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 1, color: const Color(0xFF222222),
          margin: const EdgeInsets.only(bottom: 8),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A).withValues(alpha: 0.9),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: ListView.builder(
              reverse: true, // Auto-scroll to bottom behavior
              itemCount: logs.length + 2, // Account for the command line entry
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 32),
                        Text('> root@int650:~#', style: DesignSystem.dataMono.copyWith(fontSize: 9, color: DesignSystem.primary)),
                        const SizedBox(width: 4),
                        Container(width: 6, height: 12, color: DesignSystem.primary),
                      ],
                    ),
                  );
                } else if (index == 1) {
                  return const SizedBox(height: 4); // Spacing
                } else {
                  final log = logs.reversed.toList()[index - 2];
                  String status = 'SYS';
                  Color? col = Colors.white;
                  switch (log.level) {
                    case LogLevel.info:
                      status = 'OK';
                      col = DesignSystem.primary;
                      break;
                    case LogLevel.warning:
                      status = 'WARN';
                      col = const Color(0xFFFFB300);
                      break;
                    case LogLevel.error:
                      status = 'ERR';
                      col = const Color(0xFFFF3333);
                      break;
                  }
                  return FadeSlideReveal(
                    delay: Duration(milliseconds: 50 * (index < 10 ? index : 10)),
                    duration: const Duration(milliseconds: 200),
                    child: _logLine(status, log.message, col),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _logLine(String status, String msg, Color? col, {bool indent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (indent) const SizedBox(width: 24),
          if (!indent)
            SizedBox(
              width: 32,
              child: Text(
                '[$status]',
                style: DesignSystem.dataMono.copyWith(fontSize: 9, color: col ?? Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '> $msg',
              style: DesignSystem.dataMono.copyWith(fontSize: 9, color: col ?? const Color(0xFF888888)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0A0A0A));

    final paint1 = Paint()
      ..color = DesignSystem.primary.withValues(alpha: 0.15)
      ..strokeWidth = 1;
      
    final paint2 = Paint()
      ..color = DesignSystem.primary.withValues(alpha: 0.02)
      ..strokeWidth = 1;

    // Dot grid
    for (double x = 0; x < size.width; x += 20) {
      for (double y = 0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1, paint1);
      }
    }
    
    // Lines grid
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint2);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanlinePainter extends CustomPainter {
  final double progress;
  _ScanlinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = (progress * 2 - 1) * size.height;
    final rect = Rect.fromLTRB(0, y, size.width, y + size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          DesignSystem.primary.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(rect);
    
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => oldDelegate.progress != progress;
}










