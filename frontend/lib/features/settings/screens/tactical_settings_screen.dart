import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';

class TacticalColors {
  static const background = Color(0xFF0E0E0E);
  static const primary = Color(0xFFFF0000);
  static const primaryContainer = Color(0xFF93000A);
  static const surface = Color(0xFF131313);
  static const surfaceContainerLow = Color(0xFF1C1B1B);
  static const surfaceContainer = Color(0xFF20201F);
  static const surfaceContainerHighest = Color(0xFF353535);
  static const surfaceContainerLowest = Color(0xFF0A0A0A);
  static const outline = Color(0xFF8A938B);
  static const outlineVariant = Color(0xFF404942);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFC0C9C0);
  static const secondary = Color(0xFFC6C6C6);
}

class TacticalSettingsScreen extends ConsumerStatefulWidget {
  const TacticalSettingsScreen({super.key});

  @override
  ConsumerState<TacticalSettingsScreen> createState() => _TacticalSettingsScreenState();
}

class _TacticalSettingsScreenState extends ConsumerState<TacticalSettingsScreen> {
  String _selectedTab = 'Security';
  bool biometricUplink = true;
  bool aesEncryption = true;
  bool hardStrike = false;
  bool vpnTunnel = true;
  bool dnsOverHttps = true;
  double predictiveBias = 72;
  double diagnosticDepth = 100;
  String bufferRetention = '50ms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: Column(
        children: [
          _buildTopAppBar(context),
          Expanded(
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width >= 768)
                  _buildSideNavBar(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: TacticalColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: TacticalColors.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'KRUGX',
                style: GoogleFonts.archivoNarrow(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: TacticalColors.primary,
                  letterSpacing: -1,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: TacticalColors.outlineVariant,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Text(
                'SETTINGS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TacticalColors.onSurfaceVariant,
                  letterSpacing: 0.28,
                ),
              ),
            ],
          ),
          if (MediaQuery.of(context).size.width >= 768)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: _buildSearchBar(),
              ),
            ),
          Row(
            children: [
              _buildIconButton(Icons.timer_outlined, onTap: () => context.push('/history')),
              const SizedBox(width: 8),
              _buildIconButton(Icons.sync_outlined, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing...')),
                );
              }),
              const SizedBox(width: 8),
              _buildIconButton(Icons.power_settings_new, onTap: () => context.pop()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomPaint(
      painter: BracketPainter(
        color: TacticalColors.outline,
        topLeft: true,
        bottomRight: true,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: TacticalColors.surfaceContainerLowest,
          border: Border.all(color: TacticalColors.surfaceContainerHighest),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: TacticalColors.outline, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: GoogleFonts.jetBrainsMono(
                  color: TacticalColors.primary,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'QUERY_SETTINGS...',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    color: TacticalColors.outlineVariant.withValues(alpha: 0.5),
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: TacticalColors.primary, size: 24),
      ),
    );
  }

  Widget _buildSideNavBar() {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: TacticalColors.surfaceContainerLow,
        border: Border(right: BorderSide(color: TacticalColors.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TacticalColors.surfaceContainerHighest,
                    border: Border.all(color: TacticalColors.outlineVariant),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, color: TacticalColors.secondary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KRUGX-OS',
                      style: GoogleFonts.archivoNarrow(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TacticalColors.primary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'v4.2.0-STABLE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: TacticalColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildNavItem('Security', Icons.security, isActive: _selectedTab == 'Security', onTap: () => setState(() => _selectedTab = 'Security')),
          _buildNavItem('Telemetry', Icons.analytics_outlined, onTap: () => context.push('/history')),
          _buildNavItem('AI Core', Icons.memory_outlined, onTap: () => context.go('/')),
          _buildNavItem('Network', Icons.hub_outlined, isActive: _selectedTab == 'Network', onTap: () => setState(() => _selectedTab = 'Network')),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Override Initiated')),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: TacticalColors.surfaceContainerHighest,
                  border: Border.all(color: TacticalColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: TacticalColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'INITIATE_OVERRIDE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: TacticalColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: TacticalColors.outlineVariant, height: 1),
          const SizedBox(height: 24),
          _buildNavItem('Settings', Icons.settings_outlined, onTap: () => context.push('/settings')),
          _buildNavItem('Logs', Icons.terminal_outlined, onTap: () => context.push('/history')),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color: isActive ? TacticalColors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
        border: isActive
            ? const Border(left: BorderSide(color: TacticalColors.primary, width: 4))
            : const Border(left: BorderSide(color: Colors.transparent, width: 4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? TacticalColors.primary : TacticalColors.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? TacticalColors.primary : TacticalColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildNetworkContent() {
    return CustomPaint(
      painter: GridBackgroundPainter(
        color: TacticalColors.surfaceContainerHighest,
        spacing: 24,
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          Text(
            'NETWORK CONFIG',
            style: GoogleFonts.archivoNarrow(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: TacticalColors.onSurface,
              letterSpacing: -0.96,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TacticalColors.outlineVariant)),
            ),
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'SYS_LVL_04 // ONLINE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TacticalColors.primary,
                letterSpacing: 0.28,
              ),
            ),
          ),
          const SizedBox(height: 48),
          CustomPaint(
            painter: BracketPainter(
              color: TacticalColors.outline,
              topLeft: true,
              bottomRight: true,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: TacticalColors.surfaceContainerLow,
                border: Border.all(color: TacticalColors.outlineVariant),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wifi, color: TacticalColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'UPLINK STATUS',
                        style: GoogleFonts.archivoNarrow(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: TacticalColors.onSurface,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: TacticalColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: TacticalColors.primary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CONNECTED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: TacticalColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: TacticalColors.outlineVariant, height: 1),
                  const SizedBox(height: 24),
                  _buildToggleRow(
                    'VPN Tunnel',
                    'ID: 0xNET // ENCRYPTED',
                    vpnTunnel,
                    (val) => setState(() => vpnTunnel = val),
                  ),
                  const Divider(color: TacticalColors.outlineVariant, height: 1),
                  _buildToggleRow(
                    'DNS over HTTPS',
                    'ID: 0xDOH // SECURE',
                    dnsOverHttps,
                    (val) => setState(() => dnsOverHttps = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedTab == 'Network') {
      return _buildNetworkContent();
    }
    return CustomPaint(
      painter: GridBackgroundPainter(
        color: TacticalColors.surfaceContainerHighest,
        spacing: 24,
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          Text(
            'SECURITY CONFIG',
            style: GoogleFonts.archivoNarrow(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: TacticalColors.onSurface,
              letterSpacing: -0.96,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TacticalColors.outlineVariant)),
            ),
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'SYS_LVL_04 // ACCESS_GRANTED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TacticalColors.primary,
                letterSpacing: 0.28,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // 1. Security Config
          CustomPaint(
            painter: BracketPainter(
              color: TacticalColors.outline,
              topLeft: true,
              bottomRight: true,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TacticalColors.surfaceContainer,
                border: Border.all(color: TacticalColors.outlineVariant),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AC0C0C0),
                    offset: Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Access Protocols', Icons.security),
                  Consumer(
                    builder: (context, ref, _) {
                      final settings = ref.watch(settingsProvider);
                      return _buildToggleRow(
                        'Session Persistence',
                        'ID: 0xAF3 // KEEP_ALIVE',
                        settings.persistSession,
                        (val) {
                          ref.read(settingsProvider.notifier).updatePersistSession(val);
                        },
                      );
                    }
                  ),
                  const Divider(color: TacticalColors.outlineVariant, height: 1),
                  _buildToggleRow(
                    'Biometric Uplink',
                    'ID: 0xAF4 // REQ_AUTH',
                    biometricUplink,
                    (val) => setState(() => biometricUplink = val),
                  ),
                  const Divider(color: TacticalColors.outlineVariant, height: 1),
                  _buildToggleRow(
                    'AES-256 Encryption',
                    'ID: 0xAF5 // DATA_REST',
                    aesEncryption,
                    (val) => setState(() => aesEncryption = val),
                  ),
                  const Divider(color: TacticalColors.outlineVariant, height: 1),
                  _buildToggleRow(
                    'Hard-Strike Protection',
                    'ID: 0xAF6 // PHYS_LAYER',
                    hardStrike,
                    (val) => setState(() => hardStrike = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Grid for AI Protocols and the other two
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAiProtocols()),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildBufferRetention(),
                          const SizedBox(height: 24),
                          _buildGeospatialSync(),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildAiProtocols(),
                    const SizedBox(height: 24),
                    _buildBufferRetention(),
                    const SizedBox(height: 24),
                    _buildGeospatialSync(),
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    biometricUplink = true;
                    aesEncryption = true;
                    hardStrike = false;
                    predictiveBias = 72;
                    diagnosticDepth = 100;
                    bufferRetention = '50ms';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings Reverted')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: TacticalColors.onSurface,
                  side: const BorderSide(color: TacticalColors.outline),
                  backgroundColor: TacticalColors.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  'REVERT_CHANGES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration Committed')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: TacticalColors.primary,
                  backgroundColor: TacticalColors.primaryContainer,
                  side: const BorderSide(color: TacticalColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 10,
                  shadowColor: TacticalColors.primaryContainer,
                ),
                child: Text(
                  'COMMIT_CONFIG',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildAiProtocols() {
    return CustomPaint(
      painter: BracketPainter(
        color: TacticalColors.outline,
        topRight: true,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TacticalColors.surfaceContainer,
          border: Border.all(color: TacticalColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1AC0C0C0),
              offset: Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('AI Protocols', Icons.memory),
            _buildSliderRow(
              'Predictive Bias',
              (predictiveBias / 100).toStringAsFixed(2),
              predictiveBias,
              'CONSERVATIVE',
              'AGGRESSIVE',
              (val) => setState(() => predictiveBias = val),
            ),
            const SizedBox(height: 32),
            _buildSliderRow(
              'Diagnostic Depth',
              diagnosticDepth == 100 ? 'MAX' : diagnosticDepth.toInt().toString(),
              diagnosticDepth,
              'SURFACE',
              'CORE_DUMP',
              (val) => setState(() => diagnosticDepth = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBufferRetention() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainer,
        border: Border.all(color: TacticalColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AC0C0C0),
            offset: Offset(1, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Buffer Retention', Icons.storage),
          Container(
            decoration: BoxDecoration(
              color: TacticalColors.surfaceContainerLowest,
              border: Border.all(color: TacticalColors.surfaceContainerHighest),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildSegmentButton('10ms'),
                _buildSegmentButton('50ms'),
                _buildSegmentButton('100ms'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String label) {
    final isSelected = bufferRetention == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => bufferRetention = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TacticalColors.primaryContainer : Colors.transparent,
            border: isSelected ? Border.all(color: TacticalColors.primary) : null,
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x8093000A),
                      blurRadius: 10,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? TacticalColors.primary : TacticalColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeospatialSync() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainer,
        border: Border.all(color: TacticalColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AC0C0C0),
            offset: Offset(1, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: CustomPaint(
                painter: RadarPainter(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: TacticalColors.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.satellite_alt_outlined, color: TacticalColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'GEOSPATIAL SYNC',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.onSurface,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SYSTEM ARMED',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: TacticalColors.primary,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 1.seconds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TacticalColors.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(icon, color: TacticalColors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.archivoNarrow(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TacticalColors.onSurface,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  color: TacticalColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TacticalColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          _TacticalToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
      String label, String displayValue, double value, String minLabel, String maxLabel, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: TacticalColors.onSurface,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              displayValue,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TacticalColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbShape: _TacticalSliderThumbShape(),
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: _TacticalSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minLabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: TacticalColors.onSurfaceVariant,
              ),
            ),
            Text(
              maxLabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: TacticalColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TacticalToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TacticalToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 56,
        height: 28,
        decoration: BoxDecoration(
          color: value ? TacticalColors.primaryContainer : TacticalColors.surfaceContainerLowest,
          border: Border.all(color: value ? TacticalColors.primary : TacticalColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (value)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TacticalColors.primaryContainer, Color(0xFF3F0000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: value ? 28 : 2,
              top: 1,
              bottom: 1,
              child: Container(
                width: 24,
                decoration: BoxDecoration(
                  color: value ? Colors.white : TacticalColors.secondary,
                  border: Border.all(color: TacticalColors.outline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BracketPainter extends CustomPainter {
  final Color color;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  BracketPainter({
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double length = 8;

    if (topLeft) {
      canvas.drawPath(
        Path()
          ..moveTo(0, length)
          ..lineTo(0, 0)
          ..lineTo(length, 0),
        paint,
      );
    }
    if (topRight) {
      canvas.drawPath(
        Path()
          ..moveTo(size.width - length, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, length),
        paint,
      );
    }
    if (bottomLeft) {
      canvas.drawPath(
        Path()
          ..moveTo(0, size.height - length)
          ..lineTo(0, size.height)
          ..lineTo(length, size.height),
        paint,
      );
    }
    if (bottomRight) {
      canvas.drawPath(
        Path()
          ..moveTo(size.width - length, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, size.height - length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridBackgroundPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridBackgroundPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TacticalColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2 + 20);

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    final Rect rect = Offset.zero & size;
    final gradient = RadialGradient(
      colors: [Colors.black, Colors.transparent],
      stops: const [0.4, 0.8],
      center: Alignment(0, (center.dy - size.height / 2) / (size.height / 2)),
    );
    paint.shader = gradient.createShader(rect);
    paint.style = PaintingStyle.fill;
    paint.blendMode = BlendMode.dstIn;
    canvas.drawRect(rect, paint);
    
    paint.blendMode = BlendMode.srcOver;
    paint.shader = null;

    paint.color = TacticalColors.primary;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, paint);
    paint.color = TacticalColors.primary.withValues(alpha: 0.3);
    canvas.drawCircle(center, 15, paint);
    
    paint.color = TacticalColors.secondary;
    canvas.drawCircle(Offset(center.dx + 40, center.dy - 30), 2, paint);
    canvas.drawCircle(Offset(center.dx - 80, center.dy + 40), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TacticalSliderTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 8.0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    
    final Paint paint = Paint()
      ..color = TacticalColors.surfaceContainerLowest
      ..style = PaintingStyle.fill;
    
    final Paint borderPaint = Paint()
      ..color = TacticalColors.surfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    context.canvas.drawRect(trackRect, paint);
    context.canvas.drawRect(trackRect, borderPaint);
    
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    context.canvas.drawLine(
      trackRect.topLeft,
      trackRect.bottomLeft,
      shadowPaint,
    );
    context.canvas.drawLine(
      trackRect.topLeft,
      trackRect.topRight,
      shadowPaint,
    );
  }
}

class _TacticalSliderThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(16, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Rect thumbRect = Rect.fromCenter(center: center, width: 16, height: 24);
    
    final Paint paint = Paint()
      ..color = TacticalColors.primary
      ..style = PaintingStyle.fill;
      
    final Paint borderPaint = Paint()
      ..color = TacticalColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    context.canvas.drawRect(thumbRect, paint);
    context.canvas.drawRect(thumbRect, borderPaint);
    
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    context.canvas.drawLine(
      thumbRect.topLeft,
      thumbRect.bottomLeft,
      highlightPaint,
    );
  }
}

