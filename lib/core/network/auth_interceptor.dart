// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../services/token_service.dart';

final class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final AuthRemoteDataSource authRemoteDataSource;

  AuthInterceptor({
    required this.dio,
    required this.tokenService,
    required this.authRemoteDataSource,
  });

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err); // مش 401 — سيبه يعدي
    }

    try {
      final refreshToken = await tokenService.getRefreshToken();

      final tokens = await authRemoteDataSource.refreshToken(
        refreshToken: refreshToken ?? '',
      );

      await Future.wait([
        tokenService.saveAccessToken(tokens.accessToken),
        tokenService.saveRefreshToken(tokens.refreshToken),
      ]);

      // أعد الـ request الأصلي بالـ token الجديد
      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer ${tokens.accessToken}';

      final clonedResponse = await dio.fetch(opts);
      return handler.resolve(clonedResponse);

    } catch (e) {
      // الـ refresh فشل — امسح الـ tokens وارفض بـ reject صريح
      await tokenService.clear();
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}