import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/tactical_auth_screen.dart';
import '../../features/browser/browser_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/screens/tactical_settings_screen.dart';
import '../../features/common/unimplemented_screen.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../providers/navigation_provider.dart';

CustomTransitionPage<void> _buildTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) {
        return child;
      }
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final observer = AppNavigationObserver(ref);

  final router = GoRouter(
    initialLocation: '/login',
    observers: [observer],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'SYS.ERROR',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            color: Colors.red,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text('PAGE NOT FOUND', style: TextStyle(color: Colors.red, fontFamily: 'JetBrains Mono', fontSize: 18)),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                backgroundColor: const Color(0xFF111111),
              ),
              onPressed: () => context.go('/browser'),
              child: const Text('RETURN TO BROWSER', style: TextStyle(color: Colors.red, fontFamily: 'JetBrains Mono')),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      final auth = ref.read(authProvider);

      if (auth.isLoading) return null;

      final isAuth = auth.isAuthenticated;
      final onAuthPage = state.matchedLocation == '/login';

      if (!isAuth && !onAuthPage) return '/login';
      if (isAuth && onAuthPage) return '/browser';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/browser',
      ),
      GoRoute(
        path: '/login',
        name: '/login',
        pageBuilder: (context, state) => _buildTransition(const TacticalAuthScreen(), state),
      ),
      GoRoute(
        path: '/browser',
        name: '/browser',
        pageBuilder: (context, state) => _buildTransition(const BrowserScreen(), state),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final pathName = state.uri.path.replaceAll('/', '').toUpperCase();
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: const Color(0xFF0A0A0A),
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                    backgroundColor: const Color(0xFF111111),
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/browser');
                    }
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.red, size: 18),
                ),
              ),
              title: Text(
                'SYS.$pathName',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: Colors.red,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/bookmarks',
            name: '/bookmarks',
            pageBuilder: (context, state) => _buildTransition(const BookmarksScreen(), state),
          ),
          GoRoute(
            path: '/history',
            name: '/history',
            pageBuilder: (context, state) => _buildTransition(const HistoryScreen(), state),
          ),
          GoRoute(
            path: '/settings',
            name: '/settings',
            pageBuilder: (context, state) => _buildTransition(const TacticalSettingsScreen(), state),
          ),
          GoRoute(
            path: '/profile',
            name: '/profile',
            pageBuilder: (context, state) => _buildTransition(const ProfileScreen(), state),
          ),
          GoRoute(
            path: '/garage',
            name: '/garage',
            pageBuilder: (context, state) => _buildTransition(const UnimplementedScreen(moduleName: 'SYS.GARAGE'), state),
          ),
          GoRoute(
            path: '/journeys',
            name: '/journeys',
            pageBuilder: (context, state) => _buildTransition(const UnimplementedScreen(moduleName: 'SYS.JOURNEYS'), state),
          ),
          GoRoute(
            path: '/network',
            name: '/network',
            pageBuilder: (context, state) => _buildTransition(const UnimplementedScreen(moduleName: 'SYS.NETWORK'), state),
          ),
          GoRoute(
            path: '/search',
            name: '/search',
            pageBuilder: (context, state) => _buildTransition(const UnimplementedScreen(moduleName: 'SYS.SEARCH'), state),
          ),
          GoRoute(
            path: '/lock',
            name: '/lock',
            pageBuilder: (context, state) => _buildTransition(const UnimplementedScreen(moduleName: 'SYS.LOCK'), state),
          ),
          GoRoute(
            path: '/downloads',
            name: '/downloads',
            pageBuilder: (context, state) => _buildTransition(const DownloadsScreen(), state),
          ),
        ],
      ),
    ],
  );

  ref.listen(authProvider, (previous, next) {
    if (next.isLoading) return;
    Future.microtask(() {
      if (next.isAuthenticated) {
        if (router.routerDelegate.currentConfiguration.uri.toString() == '/login') {
          router.go('/browser');
        }
      } else {
        router.go('/login');
      }
    });
  });

  return router;
});
