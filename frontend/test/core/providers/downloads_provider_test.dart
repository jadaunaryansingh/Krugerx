import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/core/providers/downloads_provider.dart';
import 'package:krugerx/core/providers/auth_provider.dart';
import 'package:krugerx/core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../dio_mock_adapter.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('downloadsProvider - fetch success populates state', () async {
    final mockAdapter = MockDioAdapter((options) async {
      if (options.path == '/downloads') {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'd1',
                'url': 'https://krugerx.ai/app.apk',
                'filename': 'app.apk',
                'mime_type': 'application/vnd.android.package-archive',
                'total_bytes': 1000,
                'status': 'completed',
                'progress': 1.0,
                'started_at': DateTime.now().toIso8601String(),
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

    expect(container.read(downloadsProvider), isEmpty);

    await container.read(downloadsProvider.notifier).fetch();
    final downloads = container.read(downloadsProvider);
    expect(downloads.length, 1);
    expect(downloads.first.filename, 'app.apk');
  });

  test('downloadsProvider - fetch error leaves state empty, no crash', () async {
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

    expect(container.read(downloadsProvider), isEmpty);

    await container.read(downloadsProvider.notifier).fetch();
    expect(container.read(downloadsProvider), isEmpty);
  });
}
