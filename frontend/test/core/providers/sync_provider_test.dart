// sync_provider_test.dart
// Sync feature is not yet implemented in features/. This file is a placeholder.
// It tests that the settings provider (the only local sync source) starts with default values.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/features/settings/providers/settings_provider.dart';
import '../../test_helper.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  test('settingsProvider - initial synced flag is false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(settingsProvider);
    expect(state.synced, isFalse);
  });
}
