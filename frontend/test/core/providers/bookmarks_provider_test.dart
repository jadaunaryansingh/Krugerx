import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/core/providers/bookmarks_provider.dart';
import 'package:krugerx/core/providers/auth_provider.dart';
import 'package:krugerx/core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../dio_mock_adapter.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('bookmarksProvider - fetch success populates state', () async {
    final mockAdapter = MockDioAdapter((options) async {
      if (options.path == '/bookmarks/folders/tree') {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'folder1',
                'name': 'My Bookmarks',
                'bookmarks': [
                  {
                    'id': 'b1',
                    'url': 'https://krugerx.ai',
                    'title': 'KrugerX',
                    'added_at': DateTime.now().toIso8601String(),
                  }
                ],
                'subfolders': []
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

    expect(container.read(bookmarksProvider), isEmpty);

    await container.read(bookmarksProvider.notifier).fetch();
    final bookmarks = container.read(bookmarksProvider);
    expect(bookmarks.length, 1);
    expect(bookmarks.first.name, 'My Bookmarks');
    expect(bookmarks.first.bookmarks.first.url, 'https://krugerx.ai');
  });

  test('bookmarksProvider - fetch error leaves state empty, no crash', () async {
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

    expect(container.read(bookmarksProvider), isEmpty);

    await container.read(bookmarksProvider.notifier).fetch();
    expect(container.read(bookmarksProvider), isEmpty);
  });
}
