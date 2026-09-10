import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/design_system.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Center(child: CircularProgressIndicator(color: DesignSystem.primary));
    }

    final displayName = authState.displayName ?? 'User';
    final email = authState.email ?? '';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return ColoredBox(
      color: const Color(0xFF0A0A0A),
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          // ── Avatar card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignSystem.primary.withValues(alpha: 0.08),
                  const Color(0xFF111111),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignSystem.primary.withValues(alpha: 0.1),
                    border: Border.all(color: DesignSystem.primary, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: authState.avatarUrl != null
                      ? ClipOval(child: Image.network(authState.avatarUrl!, width: 72, height: 72, fit: BoxFit.cover))
                      : Text(
                          initials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: DesignSystem.primary,
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.w700,
                            color: DesignSystem.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Quick actions ─────────────────────────────────────────
          _sectionLabel('QUICK ACTIONS'),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () => context.push('/history'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.bookmarks_rounded,
                label: 'Bookmarks',
                onTap: () => context.push('/bookmarks'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.download_outlined,
                label: 'Downloads',
                onTap: () => context.push('/downloads'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Account details ───────────────────────────────────────
          _sectionLabel('ACCOUNT'),
          const SizedBox(height: 12),

          _ProfileTile(
            icon: Icons.person_outline_rounded,
            label: 'Display Name',
            value: displayName,
          ),
          _ProfileTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
          ),
          _ProfileTile(
            icon: Icons.devices_rounded,
            label: 'Synced Devices',
            value: 'Manage devices',
            onTap: () => _showDevices(context, ref),
          ),
          _ProfileTile(
            icon: Icons.history_edu_rounded,
            label: 'Activity Logs',
            value: 'View browsing history',
            onTap: () => context.push('/history'),
          ),
          _ProfileTile(
            icon: Icons.feedback_outlined,
            label: 'Send Feedback',
            value: 'Report issues or suggest features',
            onTap: () => _showFeedback(context),
          ),

          const SizedBox(height: 32),

          // ── Danger zone ───────────────────────────────────────────
          _sectionLabel('ACCOUNT ACTIONS'),
          const SizedBox(height: 12),

          _DangerTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 8),
          _DangerTile(
            icon: Icons.delete_forever_rounded,
            label: 'Delete Account',
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF181818),
                  title: const Text('Delete Account?', style: TextStyle(color: Color(0xFFE0E0E0))),
                  content: const Text(
                    'This is irreversible. All synced data will be deleted.',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                final success = await ref.read(authProvider.notifier).deleteAccount();
                if (success && context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  static Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 10,
      letterSpacing: 2.5,
      color: Color(0xFF555555),
      fontWeight: FontWeight.w700,
    ),
  );

  static void _showDevices(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DevicesSheet(ref: ref),
    );
  }

  static void _showFeedback(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181818),
        title: const Text('Send Feedback', style: TextStyle(color: Color(0xFFE0E0E0))),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: const TextStyle(color: Color(0xFFE0E0E0)),
          decoration: InputDecoration(
            hintText: 'Describe the issue or suggestion...',
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent — thank you!'), backgroundColor: Color(0xFF1A1A1A)),
              );
            },
            child: Text('SEND', style: TextStyle(color: DesignSystem.primary)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────── Quick action button ────────────────────
class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}
class _QuickActionState extends State<_QuickAction> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _hover ? DesignSystem.primary.withValues(alpha: 0.1) : const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hover ? DesignSystem.primary.withValues(alpha: 0.4) : const Color(0xFF222222),
              ),
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: _hover ? DesignSystem.primary : const Color(0xFF888888), size: 22),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: _hover ? DesignSystem.primary : const Color(0xFF888888),
                    fontFamily: 'JetBrains Mono',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── Profile info tile ──────────────────────
class _ProfileTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _ProfileTile({required this.icon, required this.label, required this.value, this.onTap});

  @override
  State<_ProfileTile> createState() => _ProfileTileState();
}
class _ProfileTileState extends State<_ProfileTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _hover && widget.onTap != null ? const Color(0xFF131313) : Colors.transparent,
            border: const Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: const Color(0xFF555555)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF666666), letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(widget.value,
                        style: const TextStyle(fontSize: 14, color: Color(0xFFE0E0E0))),
                  ],
                ),
              ),
              if (widget.onTap != null)
                Icon(Icons.chevron_right_rounded,
                    size: 18,
                    color: _hover ? DesignSystem.primary : const Color(0xFF444444)),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── Danger tile ───────────────────────────
class _DangerTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DangerTile({required this.icon, required this.label, required this.onTap});

  @override
  State<_DangerTile> createState() => _DangerTileState();
}
class _DangerTileState extends State<_DangerTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _hover ? Colors.red.withValues(alpha: 0.08) : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hover ? Colors.red.withValues(alpha: 0.4) : const Color(0xFF222222)),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 16),
              Text(widget.label,
                  style: TextStyle(fontSize: 14, color: Colors.red.shade400, fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: _hover ? Colors.red.shade400 : const Color(0xFF444444)),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── Devices bottom sheet ───────────────────
class _DevicesSheet extends ConsumerWidget {
  final WidgetRef ref;
  const _DevicesSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Synced Devices',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0))),
        const SizedBox(height: 16),
        Flexible(
          child: FutureBuilder<List<dynamic>>(
            future: ref.read(authProvider.notifier).getDevices(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: DesignSystem.primary),
                );
              }
              final devices = snap.data ?? [];
              if (devices.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No other devices found.', style: TextStyle(color: Color(0xFF888888))),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (ctx, i) {
                  final d = devices[i];
                  return ListTile(
                    leading: Icon(
                      d['device_type'] == 'mobile' ? Icons.phone_android : Icons.computer,
                      color: DesignSystem.primary,
                    ),
                    title: Text(d['device_name'] ?? 'Unknown', style: const TextStyle(color: Color(0xFFE0E0E0))),
                    subtitle: Text('OS: ${d['os'] ?? 'Unknown'}', style: const TextStyle(color: Color(0xFF888888))),
                    trailing: IconButton(
                      icon: const Icon(Icons.link_off_rounded, color: Colors.red),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).removeDevice(d['id']);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
