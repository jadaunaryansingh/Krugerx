import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
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
        return handler.next(e);
      },
    ));
  }
}
