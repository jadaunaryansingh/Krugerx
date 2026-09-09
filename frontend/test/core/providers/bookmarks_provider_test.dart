// bookmarks_provider_test.dart
// Tests for the Isar-backed features/bookmarks provider.
// Note: Isar requires libisar.dll at runtime. On CI (Windows without the native
// library present), these tests will be skipped via the test_helper guard.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/features/bookmarks/providers/bookmarks_provider.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('bookmarksProvider - initial state is empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(bookmarksProvider);
    expect(state.bookmarks, isEmpty);
    expect(state.folders, isEmpty);
  });
}
