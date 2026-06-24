import 'package:dio/dio.dart';
import 'network_exceptions.dart';

final class ApiService {
  final Dio _dio;

  const ApiService(this._dio);

  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
      String endpoint, {
        Map<String, dynamic>? data,
      }) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    }
  }
}

// ── Response Wrapper ──────────────────────────────────────────
final class ApiResponse<T> {
  final bool success;
  final T? data;

  const ApiResponse({
    required this.success,
    this.data,
  });

  // بيتعامل مع الـ structure بتاعك
  // { "success": true, "data": { ... } }
  factory ApiResponse.fromResponse(Response response) {
    final body = response.data as Map<String, dynamic>?;

    return ApiResponse(
      success: body?['success'] as bool? ?? false,
      data: body?['data'] as T?,
    );
  }
}