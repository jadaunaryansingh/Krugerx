import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speed_dial_provider.dart';
import 'stats_card.dart';
import 'qr_scanner_sheet.dart';
import '../../../theme.dart';
import '../../../core/responsive.dart';

class HomePage extends ConsumerStatefulWidget {
  final ValueChanged<String> onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late final AnimationController _glowController =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

  @override
  void dispose() {
    _searchController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.trim().isNotEmpty) {
      widget.onNavigate(query.trim());
    }
  }

  void _showQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QrScannerSheet(
        onNavigate: (url) {
          widget.onNavigate(url);
        },
      ),
    );
  }

  void _showAddShortcutDialog() {
    String name = '';
    String url = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Add Shortcut', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. GitHub'),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'URL', hintText: 'https://...'),
              keyboardType: TextInputType.url,
              onChanged: (v) => url = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty && url.isNotEmpty) {
                ref.read(speedDialProvider.notifier).add(name, url);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add', style: TextStyle(color: KrugerXTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showEditShortcutDialog(int id, String currentName, String currentUrl) {
    String name = currentName;
    String url = currentUrl;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text('Edit Shortcut', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: currentName),
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: currentUrl),
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
              onChanged: (v) => url = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(speedDialProvider.notifier).remove(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: KrugerXTheme.secondary)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty && url.isNotEmpty) {
                ref.read(speedDialProvider.notifier).update(id, name, url);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(color: KrugerXTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final speedDial = ref.watch(speedDialProvider);

    return Scaffold(
      backgroundColor: KrugerXTheme.dark.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background ambient glow (Iron Classic style)
          Positioned.fill(
            child: CustomPaint(
              painter: _IronAmbientPainter(_glowController),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: KrugerPadding.ntp(context),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // Iron Classic Branding
                        ShaderMask(
                          shaderCallback: (bounds) => KrugerXTheme.brassGradient.createShader(bounds),
                          child: Text(
                            'KrugerX',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 48,
                                  fontFamily: 'Playfair Display',
                                  letterSpacing: -1.5,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 8),
                        Text(
                          'Ride the Web.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                            letterSpacing: 2.0,
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                        
                        const SizedBox(height: 48),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: KrugerXTheme.primary.withValues(alpha: 0.05),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _submitSearch,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search or type URL...',
                              hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 12),
                                child: Icon(Icons.search_rounded, color: KrugerXTheme.primary, size: 22),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                color: colors.onSurfaceVariant,
                                onPressed: _showQrScanner,
                                tooltip: 'Scan QR Code',
                              ),
                              filled: true,
                              fillColor: colors.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: KrugerXTheme.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                        
                        const SizedBox(height: 32),

                        // Stats Dashboard
                        const StatsCard(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Speed Dial Grid
                SliverPadding(
                  padding: KrugerPadding.ntp(context),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isDesktop(context) ? 6 : 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == speedDial.length) {
                          // Add button
                          return _SpeedDialBtn(
                            icon: Icons.add_rounded,
                            label: 'Add',
                            onTap: _showAddShortcutDialog,
                            isAdd: true,
                          ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 50)));
                        }
                        
                        final entry = speedDial[index];
                        return GestureDetector(
                          onLongPress: () => _showEditShortcutDialog(entry.id, entry.name, entry.url),
                          child: _SpeedDialBtn(
                            icon: _getIconData(entry.iconName),
                            label: entry.name,
                            onTap: () => widget.onNavigate(entry.url),
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 50)));
                      },
                      childCount: speedDial.length + 1,
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? name) {
    switch (name) {
      case 'search': return Icons.search_rounded;
      case 'play_circle_outline': return Icons.play_circle_outline_rounded;
      case 'code': return Icons.code_rounded;
      case 'forum': return Icons.forum_rounded;
      case 'tag': return Icons.tag_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'layers': return Icons.layers_rounded;
      case 'work_outline': return Icons.work_outline_rounded;
      case 'auto_awesome': return Icons.auto_awesome_rounded;
      case 'star': return Icons.star_rounded;
      default: return Icons.language_rounded;
    }
  }
}

class _SpeedDialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isAdd;

  const _SpeedDialBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isAdd = false,
  });

  @override
  State<_SpeedDialBtn> createState() => _SpeedDialBtnState();
}

class _SpeedDialBtnState extends State<_SpeedDialBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 56,
            transform: Matrix4.diagonal3Values(
              _pressed ? 0.92 : 1.0,
              _pressed ? 0.92 : 1.0,
              1.0,
            ),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isAdd
                  ? Colors.transparent
                  : colors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isAdd ? colors.outline : colors.outline.withValues(alpha: 0.3),
                width: widget.isAdd ? 1.5 : 0.5,
              ),
              boxShadow: _pressed || widget.isAdd
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.isAdd ? colors.onSurfaceVariant : colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IronAmbientPainter extends CustomPainter {
  final Animation<double> animation;
  _IronAmbientPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Base dark
    canvas.drawRect(
      rect,
      Paint()..color = KrugerXTheme.dark.scaffoldBackgroundColor,
    );

    // Warm brass orb top right
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          KrugerXTheme.primary.withValues(alpha: 0.15 + (animation.value * 0.05)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2), radius: size.width * 0.6));
    canvas.drawRect(rect, paint1);

    // Deep oxblood orb bottom left
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          KrugerXTheme.secondary.withValues(alpha: 0.1 + (animation.value * 0.03)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.8), radius: size.width * 0.7));
    canvas.drawRect(rect, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
