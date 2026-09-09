import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static Dio get client => _dio;

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401 && e.requestOptions.extra['isRetry'] != true) {
          try {
            final response = await Supabase.instance.client.auth.refreshSession();
            if (response.session != null) {
              // Retry original request
              final options = e.requestOptions;
              options.headers['Authorization'] = 'Bearer ${response.session!.accessToken}';
              options.extra['isRetry'] = true;
              final retryResponse = await _dio.fetch(options);
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            debugPrint('[ApiClient] token refresh error: $e');
            // Token refresh failed, fall through to error
          }
        }
        return handler.next(e);
      },

    ));
  }
}

