// Re-export the canonical auth provider from features/auth.
// This file exists so core/ providers that import from here still compile.
// DO NOT define a second authProvider here — use the one from features/auth.
export '../../features/auth/providers/auth_provider.dart';
export '../../features/auth/providers/auth_state.dart';

// Re-export apiClientProvider so other core providers that depend on it still work.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
