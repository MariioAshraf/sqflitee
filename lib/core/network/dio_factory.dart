// lib/core/network/dio_factory.dart

import 'package:dio/dio.dart';
import '../services/token_service.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';

final class DioFactory {
  final TokenService tokenService;
  final AuthRemoteDataSource authRemoteDataSource;

  const DioFactory({
    required this.tokenService,
    required this.authRemoteDataSource,
  });

  Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 20),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenService: tokenService,
        authRemoteDataSource: authRemoteDataSource,
      ),
    );

    return dio;
  }
}