// history_screen_test.dart
// Widget test for HistoryScreen using the Isar-backed features/history provider.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:krugerx/features/history/history_screen.dart';
import 'package:krugerx/features/history/providers/history_provider.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  testWidgets('HistoryScreen renders empty state without errors', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const HistoryScreen()),
      GoRoute(path: '/browser', builder: (context, state) => const Scaffold()),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyProvider.overrideWith(() => HistoryNotifier()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    // App should render without throwing
    expect(find.byType(HistoryScreen), findsOneWidget);
  });
}
