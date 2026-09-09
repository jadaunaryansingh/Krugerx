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
    final colors = Theme.of(context).colorScheme;

    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar & Name
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: DesignSystem.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: DesignSystem.primary.withValues(alpha: 0.1),
                backgroundImage: authState.avatarUrl != null ? NetworkImage(authState.avatarUrl!) : null,
                child: authState.avatarUrl == null
                    ? const Icon(Icons.person_rounded, size: 40, color: DesignSystem.primary)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              authState.displayName ?? 'User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              authState.email ?? '',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 48),

          // Actions
          ListTile(
            leading: const Icon(Icons.devices_rounded, color: DesignSystem.primary),
            title: const Text('Synced Devices'),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline, width: 0.5),
            ),
            tileColor: colors.surfaceContainer,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: colors.surfaceContainerLow,
                builder: (ctx) => _SyncedDevicesSheet(),
              );
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.feedback_rounded, color: DesignSystem.primary),
            title: const Text('Submit Feedback'),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline, width: 0.5),
            ),
            tileColor: colors.surfaceContainer,
            onTap: () {
              // TODO: Open feedback dialog
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.history_edu_rounded, color: DesignSystem.primary),
            title: const Text('Activity Logs'),
            trailing: const Icon(Icons.chevron_right_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline, width: 0.5),
            ),
            tileColor: colors.surfaceContainer,
            onTap: () {
              // TODO: Open activity logs
            },
          ),
          const SizedBox(height: 48),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: DesignSystem.error),
            title: const Text('Log Out', style: TextStyle(color: DesignSystem.error)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline, width: 0.5),
            ),
            tileColor: colors.surfaceContainer,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: DesignSystem.error),
            title: const Text('Delete Account', style: TextStyle(color: DesignSystem.error)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline, width: 0.5),
            ),
            tileColor: colors.surfaceContainerLowest,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text('This action is irreversible and will delete all your synced data.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: DesignSystem.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                final success = await ref.read(authProvider.notifier).deleteAccount();
                if (success && context.mounted) {
                  context.go('/');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SyncedDevicesSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.outline, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Synced Devices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface)),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ref.read(authProvider.notifier).getDevices(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No devices found.'));
                }
                final devices = snapshot.data!;
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (ctx, index) {
                    final d = devices[index];
                    return ListTile(
                      leading: Icon(d['device_type'] == 'mobile' ? Icons.phone_android : Icons.computer, color: DesignSystem.primary),
                      title: Text(d['device_name'] ?? 'Unknown Device'),
                      subtitle: Text('OS: ${d['os'] ?? 'Unknown'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.link_off_rounded, color: DesignSystem.error),
                        onPressed: () async {
                          final success = await ref.read(authProvider.notifier).removeDevice(d['id']);
                          if (success && ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Device unlinked')));
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
