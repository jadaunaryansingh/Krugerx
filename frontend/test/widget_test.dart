import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krugerx/main.dart';
import 'package:krugerx/features/auth/providers/auth_provider.dart';
import 'package:krugerx/features/auth/providers/auth_state.dart';
import 'package:krugerx/features/auth/screens/tactical_auth_screen.dart';
import 'test_helper.dart';

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(isLoading: false, isAuthenticated: false);
  }
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  testWidgets('App smoke test - starts at /login', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(MockAuthNotifier.new),
        ],
        child: const KrugerxApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify we are on the login screen
    expect(find.byType(TacticalAuthScreen), findsOneWidget);
    expect(find.text('EXECUTE_AUTH'), findsOneWidget);
  });
}
