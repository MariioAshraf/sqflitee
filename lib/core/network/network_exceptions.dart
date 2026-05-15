import 'dart:io';
import 'package:dio/dio.dart';

/// كل نوع خطأ ممكن يحصل من الـ network
enum NetworkExceptionType {
  noInternet,
  timeout,
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  validationError, // 422
  rateLimited, // 429
  serverError, // 5xx
  cancelled, // المستخدم أو الكود ألغى الـ request
  badCertificate, // SSL مشكلة
  unknown,
}

/// Value object — بيحمل النوع + الرسالة + الـ statusCode مع بعض
/// الـ UI أو الـ Repo مش محتاجين يعملوا switch تاني عشان يجيبوا الـ message
final class NetworkException implements Exception {
  final NetworkExceptionType type;
  final String message;
  final int? statusCode;

  const NetworkException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  /// Factory الرئيسي — كل الـ error handling في مكان واحد
  factory NetworkException.fromError(dynamic error) {
    if (error is NetworkException) return error; // تفادي double-wrapping

    if (error is DioException) return _fromDioException(error);

    if (error is SocketException) {
      return const NetworkException(
        type: NetworkExceptionType.noInternet,
        message: 'No internet connection.',
      );
    }

    return NetworkException(
      type: NetworkExceptionType.unknown,
      message: error?.toString() ?? 'An unexpected error occurred.',
    );
  }

  // ── Private Helpers ───────────────────────────────────────────────────────

  static NetworkException _fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const NetworkException(
        type: NetworkExceptionType.timeout,
        message: 'Request timed out. Please try again.',
      ),

      DioExceptionType.cancel => const NetworkException(
        type: NetworkExceptionType.cancelled,
        message: 'Request was cancelled.',
      ),

      DioExceptionType.badCertificate => const NetworkException(
        type: NetworkExceptionType.badCertificate,
        message: 'SSL certificate error. Connection is not secure.',
      ),

      DioExceptionType.connectionError => _fromConnectionError(e),

      DioExceptionType.badResponse => _fromBadResponse(e),

      _ => const NetworkException(
        type: NetworkExceptionType.unknown,
        message: 'An unexpected error occurred.',
      ),
    };
  }

  static NetworkException _fromConnectionError(DioException e) {
    if (e.error is SocketException) {
      return const NetworkException(
        type: NetworkExceptionType.noInternet,
        message: 'No internet connection.',
      );
    }
    return const NetworkException(
      type: NetworkExceptionType.unknown,
      message: 'Connection error. Please try again.',
    );
  }

  static NetworkException _fromBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final serverMessage = _extractServerMessage(e.response?.data);

    return switch (statusCode) {
      401 => NetworkException(
        type: NetworkExceptionType.unauthorized,
        message: serverMessage ?? 'Unauthorized. Please login again.',
        statusCode: 401,
      ),
      403 => NetworkException(
        type: NetworkExceptionType.forbidden,
        message: serverMessage ?? 'You don\'t have permission.',
        statusCode: 403,
      ),
      404 => NetworkException(
        type: NetworkExceptionType.notFound,
        message: serverMessage ?? 'Resource not found.',
        statusCode: 404,
      ),
      422 => NetworkException(
        type: NetworkExceptionType.validationError,
        message: serverMessage ?? 'Validation failed.',
        statusCode: 422,
      ),
      429 => NetworkException(
        type: NetworkExceptionType.rateLimited,
        message: serverMessage ?? 'Too many requests. Please slow down.',
        statusCode: 429,
      ),
      _ when (statusCode ?? 0) >= 500 => NetworkException(
        type: NetworkExceptionType.serverError,
        message: serverMessage ?? 'Server error. Please try again later.',
        statusCode: statusCode,
      ),
      _ => NetworkException(
        type: NetworkExceptionType.unknown,
        message: serverMessage ?? 'An unexpected error occurred.',
        statusCode: statusCode,
      ),
    };
  }

  /// بيجيب الـ message من الـ response body لو موجودة
  /// بيجرب مفاتيح شائعة: message, error, detail
  static String? _extractServerMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final value = data['message'] ?? data['error'] ?? data['detail'];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  // ── Convenience Getters للـ UI ────────────────────────────────────────────

  bool get isNoInternet => type == NetworkExceptionType.noInternet;

  bool get isUnauthorized => type == NetworkExceptionType.unauthorized;

  bool get isServerError => type == NetworkExceptionType.serverError;

  bool get isTimeout => type == NetworkExceptionType.timeout;

  @override
  String toString() =>
      'NetworkException(type: $type, '
      'statusCode: $statusCode, message: $message)';
}
