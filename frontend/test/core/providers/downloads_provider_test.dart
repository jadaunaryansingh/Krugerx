// downloads_provider_test.dart
// Tests for the features/downloads Isar-backed provider.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/features/downloads/providers/downloads_provider.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('downloadsProvider - initial state is empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(downloadsProvider);
    expect(state, isEmpty);
  });
}
