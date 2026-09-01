import 'package:go_router/go_router.dart';
import 'features/browser/browser_screen.dart';
import 'features/auth/screens/tactical_auth_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/settings/screens/tactical_settings_screen.dart';
import 'features/bookmarks/screens/bookmarks_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/downloads/screens/downloads_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BrowserScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const TacticalAuthScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const TacticalSettingsScreen(),
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/downloads',
      builder: (context, state) => const DownloadsScreen(),
    ),
  ],
);
