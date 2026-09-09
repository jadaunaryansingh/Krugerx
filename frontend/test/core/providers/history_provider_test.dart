import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  test('historyProvider - fetch success populates state', () async {
    final mockAdapter = MockDioAdapter((options) async {
      if (options.path == '/history') {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': '1',
                'url': 'https://example.com',
                'title': 'Example',
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

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
    );

    // Initial state is empty
    expect(container.read(historyProvider), isEmpty);

    // Fetch populates state
    await container.read(historyProvider.notifier).fetch();
    final history = container.read(historyProvider);
    expect(history.length, 1);
    expect(history.first.url, 'https://example.com');
  });

  test('historyProvider - fetch error leaves state empty, no crash', () async {
    final mockAdapter = MockDioAdapter((options) async {
      return ResponseBody.fromString(
        jsonEncode({'error': 'server error'}),
        500,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });

    final mockApiClient = ApiClient();
    mockApiClient.dio.httpClientAdapter = mockAdapter;

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
    );

    // Initial state is empty
    expect(container.read(historyProvider), isEmpty);

    // Fetch handles error
    await container.read(historyProvider.notifier).fetch();
    expect(container.read(historyProvider), isEmpty);
  });
}
