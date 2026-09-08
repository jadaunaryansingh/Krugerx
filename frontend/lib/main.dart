import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage.dart';
import 'core/api_client.dart';
import 'core/providers/navigation_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    // .env file is missing, relies on system env or fallbacks
  }
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://fallback.supabase.co',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? 'fallback-key',
  );
  await Storage.init();
  ApiClient.init();
  runApp(
    const ProviderScope(
      child: KrugerxApp(),
    ),
  );
}

class KrugerxApp extends ConsumerWidget {
  const KrugerxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final nav = ref.watch(navigationProvider.notifier);
    
    return Focus(
      autofocus: true,
      canRequestFocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (HardwareKeyboard.instance.isAltPressed) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              final backRoute = nav.getBackRoute();
              if (backRoute != null) router.go(backRoute);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              final fwdRoute = nav.getForwardRoute();
              if (fwdRoute != null) router.go(fwdRoute);
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: MaterialApp.router(
        title: 'Krugerx Browser',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }
}
