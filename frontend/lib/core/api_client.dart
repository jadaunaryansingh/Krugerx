import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'storage.dart';
import '../features/auth/models/auth_models.dart';

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
        final session = await Storage.db.authSessions.where().findFirst();
        if (session != null && session.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            final response = await Supabase.instance.client.auth.refreshSession();
            if (response.session != null) {
              var localSession = await Storage.db.authSessions.where().findFirst();
              if (localSession != null) {
                localSession.accessToken = response.session!.accessToken;
                localSession.refreshToken = response.session!.refreshToken;
                await Storage.db.writeTxn(() async {
                  await Storage.db.authSessions.put(localSession);
                });
              }
              // Retry original request
              final options = e.requestOptions;
              options.headers['Authorization'] = 'Bearer ${response.session!.accessToken}';
              final retryResponse = await _dio.fetch(options);
              return handler.resolve(retryResponse);
            }
          } catch (_) {
            // Token refresh failed, fall through to error
          }
        }
        return handler.next(e);
      },

    ));
  }
}
