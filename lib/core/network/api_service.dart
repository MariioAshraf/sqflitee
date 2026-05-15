// lib/core/network/api_service.dart

import 'package:dio/dio.dart';
import 'api_constants.dart';

/// مسؤول عن HTTP calls فقط — zero business logic
final class ApiService {
  final Dio _dio;

  const ApiService(this._dio);

  Future<Response<Map<String, dynamic>>> post(
      String path, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<Map<String, dynamic>>> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
}