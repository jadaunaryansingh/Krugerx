import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:krugerx/features/history/history_screen.dart';
import 'package:krugerx/core/providers/history_provider.dart';
import 'package:krugerx/core/providers/auth_provider.dart';
import 'package:krugerx/core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../dio_mock_adapter.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  testWidgets('HistoryScreen - tap entry navigates to browser', (WidgetTester tester) async {
    String? navigatedUrl;
    
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/browser',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra != null) {
              navigatedUrl = extra['url'] as String?;
            }
            return const Scaffold(body: Text('Browser Screen'));
          },
        ),
      ],
    );

    final mockAdapter = MockDioAdapter((options) async {
      if (options.path == '/history') {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': '1',
                'url': 'https://example.com',
                'title': 'Example Site',
                'visit_time': DateTime.now().toIso8601String(),
                'visit_count': 1,
                'synced': true,
              }
            ]
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      return ResponseBody.fromString('Not Found', 404);
    });

    final mockApiClient = ApiClient();
    mockApiClient.dio.httpClientAdapter = mockAdapter;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify history item is displayed
    expect(find.text('Example Site'), findsOneWidget);
    expect(find.text('https://example.com'), findsOneWidget);

    // Tap the item
    await tester.tap(find.text('Example Site'));
    await tester.pumpAndSettle();

    // Verify navigation occurred with correct URL
    expect(navigatedUrl, 'https://example.com');
    expect(find.text('Browser Screen'), findsOneWidget);
  });
}
