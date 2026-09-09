// history_provider_test.dart
// Tests for the features/history Isar-backed provider.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/features/history/providers/history_provider.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('historyProvider - initial state is empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(historyProvider);
    expect(state, isEmpty);
  });
}
