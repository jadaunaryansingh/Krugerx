import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/core/providers/sync_provider.dart';
import 'package:krugerx/core/providers/auth_provider.dart';
import 'package:krugerx/core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../dio_mock_adapter.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('syncProvider - registerDevice success populates state', () async {
    final mockAdapter = MockDioAdapter((options) async {
      if (options.path == '/sync/devices') {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'device1',
              'device_name': 'My PC',
              'device_type': 'desktop',
              'os': 'windows',
              'client_version': '1.0.0',
              'last_sync_at': DateTime.now().toIso8601String(),
            }
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

    expect(container.read(syncProvider), isNull);

    await container.read(syncProvider.notifier).registerDevice('My PC', 'desktop', 'windows', '1.0.0');
    final device = container.read(syncProvider);
    expect(device, isNotNull);
    expect(device!.deviceName, 'My PC');
  });

  test('syncProvider - registerDevice error leaves state null, no crash', () async {
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

    expect(container.read(syncProvider), isNull);

    await container.read(syncProvider.notifier).registerDevice('My PC', 'desktop', 'windows', '1.0.0');
    expect(container.read(syncProvider), isNull);
  });
}
