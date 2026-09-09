import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'dart:convert';

import '../../../core/api_client.dart';
import '../../../core/storage.dart';
import '../../../core/providers/system_logger.dart';
import '../models/auth_models.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState(isLoading: true);
  }

  bool _isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payloadString = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = json.decode(payloadString);
      if (payloadMap['exp'] != null) {
        final exp = DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
        return exp.isAfter(DateTime.now());
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _init() async {
    final session = await Storage.db.authSessions.where().findFirst();
    if (session != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: session.userId,
        email: session.email,
        displayName: session.displayName,
        avatarUrl: session.avatarUrl,
      );
      _fetchMe();
    } else {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
    
    // Listen to Supabase Auth State Changes for Google OAuth
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? supabaseSession = data.session;
      
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        if (supabaseSession != null) {
          await Storage.db.writeTxn(() async {
            await Storage.db.authSessions.clear();
            final provider = supabaseSession.user.appMetadata['provider']?.toString() ?? 'unknown';
            final localSession = AuthSession()
              ..expiresIn = supabaseSession.expiresIn ?? 3600
              ..userId = supabaseSession.user.id
              ..email = supabaseSession.user.email
              ..authProvider = provider;
            await Storage.db.authSessions.put(localSession);
          });
          
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            userId: supabaseSession.user.id,
            email: supabaseSession.user.email,
          );
          
          if (event == AuthChangeEvent.signedIn) {
            ref.read(systemLoggerProvider.notifier).addLog(LogLevel.info, 'AUTH: Google Login successful');
            _fetchMe();
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // Clear session if signed out from Supabase (e.g. token revocation)
        await Storage.db.writeTxn(() async {
          await Storage.db.authSessions.clear();
        });
        state = const AuthState(isLoading: false, isAuthenticated: false);
      }
    });
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.origin : 'krugerx://login-callback',
      );
      // We keep isLoading true while waiting for onAuthStateChange
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Google Login failed: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];

        // Hydrate Supabase SDK so it handles background token refresh
        try {
          await Supabase.instance.client.auth.setSession(data['refresh_token']);
        } catch (e) {
          // If setting session fails, log it
        }

        final localSession = AuthSession()
          ..expiresIn = data['expires_in'] ?? 3600
          ..userId = data['user_id']
          ..email = email
          ..authProvider = 'email';
          
        await Storage.db.writeTxn(() async {
          await Storage.db.authSessions.clear();
          await Storage.db.authSessions.put(localSession);
        });

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userId: data['user_id'],
          email: email,
        );

        ref.read(systemLoggerProvider.notifier).addLog(LogLevel.info, 'AUTH: Login successful for $email');

        await _fetchMe();
        return true;
      }
    } on DioException catch (e) {
      final msg = _extractDioError(e, fallback: 'Login failed. Check your credentials.');
      state = state.copyWith(isLoading: false, error: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred: $e');
    }
    return false;
  }

  Future<bool> signup(String email, String password, String? displayName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.client.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      });

      if (response.statusCode == 201 && response.data['success']) {
        state = state.copyWith(isLoading: false);
        ref.read(systemLoggerProvider.notifier).addLog(LogLevel.info, 'AUTH: Registration successful for $email');
        // Try to auto-login. If email confirmation is required, login will fail.
        final loginSuccess = await login(email, password);
        if (!loginSuccess) {
          state = state.copyWith(
            isLoading: false, 
            error: 'REGISTRATION_SUCCESS // AWAITING_EMAIL_CONFIRMATION'
          );
          return false;
        }
        return true;
      }
      // Non-201 success=false
      final msg = response.data['message'] as String? ?? 'Signup failed.';
      state = state.copyWith(isLoading: false, error: msg);
    } on DioException catch (e) {
      final msg = _extractDioError(e, fallback: 'Signup failed.');
      state = state.copyWith(isLoading: false, error: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred: $e');
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.client.post('/auth/reset-password', data: {
        'email': email,
      });

      if (response.statusCode == 200 && response.data['success']) {
        state = state.copyWith(isLoading: false);
        ref.read(systemLoggerProvider.notifier).addLog(LogLevel.info, 'AUTH: Password reset requested for $email');
        return true;
      }
      final msg = response.data['message'] as String? ?? 'Password reset failed.';
      state = state.copyWith(isLoading: false, error: msg);
    } on DioException catch (e) {
      final msg = _extractDioError(e, fallback: 'Password reset failed.');
      state = state.copyWith(isLoading: false, error: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred: $e');
    }
    return false;
  }

  Future<void> logout() async {
    state = const AuthState();
    
    await Storage.db.writeTxn(() async {
      await Storage.db.authSessions.clear();
    });

    // Attempt Supabase signOut first for Google OAuth
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // Ignore
    }

    try {
      await ApiClient.client.post('/auth/logout');
    } catch (e) {
      // Ignore network errors on logout
    }
    
    ref.read(systemLoggerProvider.notifier).addLog(LogLevel.info, 'AUTH: User logged out');
  }

  Future<void> _fetchMe() async {
    try {
      final response = await ApiClient.client.get('/auth/me');
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        final profile = data['profile'] ?? {};

        final session = await Storage.db.authSessions.where().findFirst();
        if (session != null) {
          await Storage.db.writeTxn(() async {
            session.displayName = profile['display_name'];
            session.avatarUrl = profile['avatar_url'];
            await Storage.db.authSessions.put(session);
          });
        }

        state = state.copyWith(
          displayName: profile['display_name'],
          avatarUrl: profile['avatar_url'],
        );
      }
    } catch (e) {
      // Background fetch failed, ignore
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final response = await ApiClient.client.delete('/auth/account');
      if (response.statusCode == 200) {
        await logout();
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete account');
    }
    return false;
  }

  Future<List<dynamic>> getDevices() async {
    try {
      final response = await ApiClient.client.get('/sync/devices');
      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      // Ignore
    }
    return [];
  }

  Future<bool> removeDevice(String deviceId) async {
    try {
      final response = await ApiClient.client.delete('/sync/devices/$deviceId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearSyncQueue() async {
    try {
      final response = await ApiClient.client.delete('/sync/clear');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Safely extracts an error message from a DioException.
  /// FastAPI can return `detail` as a String OR a List of validation errors.
  String _extractDioError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        // FastAPI validation error: [{loc, msg, type}]
        final first = detail.first;
        if (first is Map) {
          final loc = (first['loc'] as List?)?.join('.') ?? '';
          final msg = first['msg'] as String? ?? '';
          return loc.isNotEmpty ? '$loc: $msg' : msg;
        }
      }
      return data['message'] as String? ?? fallback;
    }
    return e.message ?? fallback;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
