import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_system.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';

class TacticalSettingsScreen extends ConsumerStatefulWidget {
  const TacticalSettingsScreen({super.key});

  @override
  ConsumerState<TacticalSettingsScreen> createState() => _TacticalSettingsScreenState();
}

class _TacticalSettingsScreenState extends ConsumerState<TacticalSettingsScreen> {
  String _selectedSection = 'General';

  static const _sections = [
    ('General',  Icons.tune_rounded),
    ('Privacy',  Icons.shield_outlined),
    ('Search',   Icons.search_rounded),
    ('AI',       Icons.psychology_outlined),
    ('About',    Icons.info_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Row(
      children: [
        // Sidebar
        Container(
          width: 220,
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D0D),
            border: Border(right: BorderSide(color: Color(0xFF222222))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              for (final (label, icon) in _sections)
                _SideItem(
                  label: label,
                  icon: icon,
                  selected: _selectedSection == label,
                  onTap: () => setState(() => _selectedSection = label),
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: ColoredBox(
            color: const Color(0xFF0A0A0A),
            child: _buildSection(settings),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(settings) {
    return switch (_selectedSection) {
      'General' => _GeneralSection(settings: settings),
      'Privacy' => _PrivacySection(settings: settings),
      'Search'  => _SearchSection(settings: settings),
      'AI'      => _AiSection(settings: settings),
      'About'   => _AboutSection(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ──────────────────────── Sidebar item ──────────────────────────
class _SideItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SideItem({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  State<_SideItem> createState() => _SideItemState();
}
class _SideItemState extends State<_SideItem> {
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
          decoration: BoxDecoration(
            color: widget.selected
                ? DesignSystem.primary.withValues(alpha: 0.12)
                : _hover ? const Color(0xFF1A1A1A) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: widget.selected ? DesignSystem.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(widget.icon, size: 18,
                  color: widget.selected ? DesignSystem.primary : const Color(0xFF888888)),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
                  color: widget.selected ? DesignSystem.primary : const Color(0xFF888888),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── Reusable tile ─────────────────────────
class _SettingsTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget trailing;
  const _SettingsTile({required this.label, this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 14, color: Color(0xFFE0E0E0), fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }
}

Widget _sectionHeader(String title) => Padding(
  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
  child: Text(
    title.toUpperCase(),
    style: const TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 10,
      letterSpacing: 2.5,
      color: Color(0xFF555555),
      fontWeight: FontWeight.w700,
    ),
  ),
);

Switch _redSwitch(bool value, ValueChanged<bool> onChanged) => Switch(
  value: value,
  onChanged: onChanged,
  activeColor: DesignSystem.primary,
  activeTrackColor: DesignSystem.primary.withValues(alpha: 0.3),
  inactiveThumbColor: const Color(0xFF444444),
  inactiveTrackColor: const Color(0xFF222222),
);

// ──────────────────────── GENERAL ───────────────────────────────
class _GeneralSection extends ConsumerWidget {
  final dynamic settings;
  const _GeneralSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _sectionHeader('Appearance'),
        _SettingsTile(
          label: 'Theme',
          subtitle: 'Interface color scheme',
          trailing: DropdownButton<String>(
            value: settings.theme ?? 'dark',
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
            underline: const SizedBox.shrink(),
            onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).updateTheme(v); },
            items: const [
              DropdownMenuItem(value: 'dark', child: Text('Dark')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
              DropdownMenuItem(value: 'system', child: Text('System')),
            ],
          ),
        ),
        _SettingsTile(
          label: 'Font Size',
          subtitle: 'Base font size for web pages',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                color: DesignSystem.primary,
                onPressed: () {
                  final cur = settings.fontSize ?? 14;
                  if (cur > 10) ref.read(settingsProvider.notifier).updateFontSize(cur - 1);
                },
              ),
              Text('${settings.fontSize ?? 14}px',
                  style: const TextStyle(color: Color(0xFFE0E0E0), fontFamily: 'JetBrains Mono', fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: DesignSystem.primary,
                onPressed: () {
                  final cur = settings.fontSize ?? 14;
                  if (cur < 32) ref.read(settingsProvider.notifier).updateFontSize(cur + 1);
                },
              ),
            ],
          ),
        ),
        _sectionHeader('Session'),
        _SettingsTile(
          label: 'Persist Session',
          subtitle: 'Stay logged in between restarts',
          trailing: _redSwitch(settings.persistSession ?? true,
              (v) => ref.read(settingsProvider.notifier).updatePersistSession(v)),
        ),
        _sectionHeader('Language'),
        _SettingsTile(
          label: 'Language',
          subtitle: 'UI language',
          trailing: DropdownButton<String>(
            value: settings.language ?? 'en',
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
            underline: const SizedBox.shrink(),
            onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).updateLanguage(v); },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'hi', child: Text('Hindi')),
              DropdownMenuItem(value: 'es', child: Text('Spanish')),
            ],
          ),
        ),
        _SettingsTile(
          label: 'Homepage',
          subtitle: settings.homepageUrl?.isNotEmpty == true ? settings.homepageUrl : 'New Tab',
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: DesignSystem.primary,
            onPressed: () => _editHomepage(context, ref, settings.homepageUrl ?? ''),
          ),
        ),
      ],
    );
  }

  Future<void> _editHomepage(BuildContext context, WidgetRef ref, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181818),
        title: const Text('Homepage URL', style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Color(0xFFE0E0E0)),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: const TextStyle(color: Color(0xFF555555)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('SAVE', style: TextStyle(color: DesignSystem.primary)),
          ),
        ],
      ),
    );
    if (result != null) ref.read(settingsProvider.notifier).updateHomepageUrl(result);
  }
}

// ──────────────────────── PRIVACY ───────────────────────────────
class _PrivacySection extends ConsumerWidget {
  final dynamic settings;
  const _PrivacySection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _sectionHeader('Tracking & Security'),
        _SettingsTile(
          label: 'Tracking Protection',
          subtitle: 'Block known tracking scripts',
          trailing: _redSwitch(settings.privacyTrackingProtection,
              (v) => ref.read(settingsProvider.notifier).updatePrivacy(v)),
        ),
        _SettingsTile(
          label: 'DNS over HTTPS',
          subtitle: 'Encrypt DNS queries',
          trailing: _redSwitch(settings.dnsOverHttps,
              (v) => ref.read(settingsProvider.notifier).updateDnsOverHttps(v)),
        ),
        _sectionHeader('Encryption'),
        _SettingsTile(
          label: 'AES Encryption',
          subtitle: 'Encrypt local stored data',
          trailing: _redSwitch(settings.aesEncryption,
              (v) => ref.read(settingsProvider.notifier).updateAesEncryption(v)),
        ),
        _SettingsTile(
          label: 'Biometric Uplink',
          subtitle: 'Require biometric for sensitive ops',
          trailing: _redSwitch(settings.biometricUplink,
              (v) => ref.read(settingsProvider.notifier).updateBiometricUplink(v)),
        ),
        _sectionHeader('Advanced'),
        _SettingsTile(
          label: 'Hard Strike Mode',
          subtitle: 'Zero-tolerance on suspicious traffic',
          trailing: _redSwitch(settings.hardStrike,
              (v) => ref.read(settingsProvider.notifier).updateHardStrike(v)),
        ),
        _SettingsTile(
          label: 'VPN Tunnel',
          subtitle: 'Route traffic through secure tunnel',
          trailing: _redSwitch(settings.vpnTunnel,
              (v) => ref.read(settingsProvider.notifier).updateVpnTunnel(v)),
        ),
        _sectionHeader('Data'),
        _SettingsTile(
          label: 'Clear Browsing Data',
          subtitle: 'History, cache, cookies',
          trailing: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.5)),
              foregroundColor: DesignSystem.primary,
              textStyle: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11),
            ),
            onPressed: () => _confirmClear(context, ref),
            child: const Text('CLEAR'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181818),
        title: const Text('Clear all data?', style: TextStyle(color: Color(0xFFE0E0E0))),
        content: const Text('This will clear browsing history and local data.',
            style: TextStyle(color: Color(0xFF888888))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('CLEAR', style: TextStyle(color: DesignSystem.primary)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ref.read(historyProvider.notifier).clearAll();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Browsing data cleared'), backgroundColor: Color(0xFF1A1A1A)),
      );
    }
  }
}

// ──────────────────────── SEARCH ────────────────────────────────
class _SearchSection extends ConsumerWidget {
  final dynamic settings;
  const _SearchSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _sectionHeader('Default Search Engine'),
        _SettingsTile(
          label: 'Search Engine',
          subtitle: 'Used when typing in address bar',
          trailing: DropdownButton<String>(
            value: settings.searchEngine ?? 'google',
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
            underline: const SizedBox.shrink(),
            onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).updateSearchEngine(v); },
            items: const [
              DropdownMenuItem(value: 'duckduckgo', child: Text('DuckDuckGo')),
              DropdownMenuItem(value: 'google', child: Text('Google')),
              DropdownMenuItem(value: 'bing', child: Text('Bing')),
              DropdownMenuItem(value: 'kruger', child: Text('KrugerSearch (Native)')),
            ],
          ),
        ),
        _sectionHeader('Suggestions'),
        _SettingsTile(
          label: 'History Suggestions',
          subtitle: 'Show past URLs while typing',
          trailing: _redSwitch(settings.historySuggestions,
              (v) => ref.read(settingsProvider.notifier).updateHistorySuggestions(v)),
        ),
      ],
    );
  }
}

// ──────────────────────── AI ────────────────────────────────────
class _AiSection extends ConsumerWidget {
  final dynamic settings;
  const _AiSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _sectionHeader('AI Provider'),
        _SettingsTile(
          label: 'Provider',
          subtitle: 'AI service for the sidebar assistant',
          trailing: DropdownButton<String>(
            value: settings.aiProvider ?? 'gemini',
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
            underline: const SizedBox.shrink(),
            onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).updateAiProvider(v); },
            items: const [
              DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
              DropdownMenuItem(value: 'local', child: Text('Local (Ollama)')),
            ],
          ),
        ),
        _SettingsTile(
          label: 'Model',
          subtitle: 'Model to use for AI responses',
          trailing: DropdownButton<String>(
            value: settings.aiModel ?? 'gemini-pro',
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
            underline: const SizedBox.shrink(),
            onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).updateAiModel(v); },
            items: const [
              DropdownMenuItem(value: 'gemini-pro', child: Text('Gemini Pro')),
              DropdownMenuItem(value: 'gemini-flash', child: Text('Gemini Flash')),
              DropdownMenuItem(value: 'gpt-4o', child: Text('GPT-4o')),
              DropdownMenuItem(value: 'gpt-4o-mini', child: Text('GPT-4o Mini')),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────── ABOUT ─────────────────────────────────
class _AboutSection extends ConsumerWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _sectionHeader('Application'),
        _SettingsTile(
          label: 'KrugerX Browser',
          subtitle: 'Version 1.0.0 — Windows x64',
          trailing: const Icon(Icons.verified_outlined, color: Color(0xFF555555), size: 18),
        ),
        _SettingsTile(
          label: 'Runtime',
          subtitle: 'Flutter • WebView2 (Microsoft Edge)',
          trailing: const Icon(Icons.web, color: Color(0xFF555555), size: 18),
        ),
        _SettingsTile(
          label: 'Backend',
          subtitle: 'FastAPI • Python 3.11 • Supabase',
          trailing: const Icon(Icons.dns_outlined, color: Color(0xFF555555), size: 18),
        ),
        _SettingsTile(
          label: 'Storage',
          subtitle: 'Isar (local) • Supabase PostgreSQL (cloud)',
          trailing: const Icon(Icons.storage_outlined, color: Color(0xFF555555), size: 18),
        ),
        _sectionHeader('Account'),
        _SettingsTile(
          label: 'Sign Out',
          subtitle: 'Log out of your account',
          trailing: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: DesignSystem.primary.withValues(alpha: 0.5)),
              foregroundColor: DesignSystem.primary,
              textStyle: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11),
            ),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('LOGOUT'),
          ),
        ),
      ],
    );
  }
}
