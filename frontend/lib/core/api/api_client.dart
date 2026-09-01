import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? _getDefaultBaseUrl(),
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // If we get a 401, it means the token is truly invalid (or the SDK's background refresh failed)
          // Force a sign out to clear the session and prompt the user to log in again.
          try {
            await Supabase.instance.client.auth.signOut();
          } catch (_) {}
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('access_token');
          await prefs.remove('refresh_token');
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  static String _getDefaultBaseUrl() {
    return 'https://krugerx-backend.onrender.com/api/v1';
  }
}
