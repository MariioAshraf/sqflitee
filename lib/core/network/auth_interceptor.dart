// lib/core/network/auth_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../services/token_service.dart';

/// الـ Interceptor المسؤول عن:
/// 1. حقن الـ access token في كل request
/// 2. اعتراض أي 401 وعمل refresh تلقائي
/// 3. منع تعدد طلبات الـ refresh في نفس الوقت (queue + lock)
/// 4. إعادة إرسال الـ request الأصلي تلقائياً بعد الـ refresh
/// 5. لو الـ refresh فشل — مسح كل التوكنز (الـ caller هيكتشف ويرجع login)
final class AuthInterceptor extends Interceptor {
  late final Dio dio; // ← يتحدد بعد الإنشاء
  final TokenService _tokenService;
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthInterceptor({
    required TokenService tokenService,
    required AuthRemoteDataSource authRemoteDataSource,
  })  : _tokenService = tokenService,
        _authRemoteDataSource = authRemoteDataSource;

  // ── Lock state ──────────────────────────────────────────────────────────
  // true لو في refresh شغال دلوقتي — أي request تاني هيستنى في الـ queue
  bool _isRefreshing = false;

  // الـ queue: كل request وقعت بـ 401 وقت ما الـ refresh شغال
  // بتستنى هنا لحد ما الـ refresh يخلص (نجاح أو فشل)
  final List<Completer<void>> _refreshQueue = [];

  // عشان نمنع infinite loop — لو الـ request اللي فشلت هي نفسها
  // retry بعد refresh وفشلت تاني بـ 401، مانعملش refresh تاني عليها
  static const _retryFlag = 'x-retried-after-refresh';

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _tokenService.getAccessToken();
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
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshEndpoint =
    err.requestOptions.path.contains('/auth/refresh');
    final alreadyRetried =
        err.requestOptions.extra[_retryFlag] == true;

    // ── Skip cases ──────────────────────────────────────────────────────
    // 1. مش 401 → مفيش لازمة نتدخل
    // 2. الـ request اللي فشلت هي نفسها /auth/refresh → منعملش refresh للـ refresh
    // 3. الـ request دي بالفعل retried قبل كده بعد refresh وفشلت تاني → منع infinite loop
    if (!isUnauthorized || isRefreshEndpoint || alreadyRetried) {
      if (isUnauthorized && (isRefreshEndpoint || alreadyRetried)) {
        // الـ refresh نفسه فشل، أو الـ retry فشل تاني — اعتبرها جلسة منتهية
        await _forceLogout();
      }
      return handler.next(err);
    }

    // ── لو في refresh شغال دلوقتي — استنى في الـ queue ───────────────────
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);

      try {
        await completer.future; // بيستنى لحد ما الـ refresh يخلص
      } catch (_) {
        // الـ refresh فشل لكل الـ queue
        return handler.reject(err);
      }

      // الـ refresh نجح — أعد الـ request بالـ token الجديد
      return _retryRequest(err, handler);
    }

    // ── أنا أول واحد واصل بـ 401 — أنا اللي هعمل الـ refresh ─────────────
    _isRefreshing = true;

    try {
      final refreshToken = await _tokenService.getRefreshToken();

      if (refreshToken == null) {
        throw const _RefreshFailedException('No refresh token found');
      }

      await _authRemoteDataSource.refreshToken(refreshToken: refreshToken);

      // ── الـ refresh نجح ──────────────────────────────────────────────
      _isRefreshing = false;
      _resolveQueue(); // فضّي الـ queue كله بنجاح

      return _retryRequest(err, handler);
    } catch (e) {
      // ── الـ refresh فشل ──────────────────────────────────────────────
      _isRefreshing = false;
      _rejectQueue(e); // فضّي الـ queue كله بفشل

      await _forceLogout();
      return handler.reject(err);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  /// بيعيد إرسال الـ request الأصلي بنفس الـ RequestOptions
  /// بعد ما الـ Authorization header يتحدث بالـ token الجديد
  Future<void> _retryRequest(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    try {
      final newToken = await _tokenService.getAccessToken();

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      // علّم الـ request دي إنها retried عشان منعملش refresh تاني لو فشلت
      retryOptions.extra[_retryFlag] = true;

      final response = await dio.fetch(retryOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.reject(
        e is DioException
            ? e
            : DioException(requestOptions: err.requestOptions, error: e),
      );
    }
  }

  void _resolveQueue() {
    for (final completer in _refreshQueue) {
      if (!completer.isCompleted) completer.complete();
    }
    _refreshQueue.clear();
  }

  void _rejectQueue(Object error) {
    for (final completer in _refreshQueue) {
      if (!completer.isCompleted) completer.completeError(error);
    }
    _refreshQueue.clear();
  }

  Future<void> _forceLogout() async {
    await _tokenService.clearAll();
    // الـ SplashCubit / LoginCubit / router guard هيكتشف غياب الـ token
    // ويوجّه المستخدم لـ login تلقائياً — الـ interceptor مش مسؤول عن navigation
  }
}

final class _RefreshFailedException implements Exception {
  final String message;
  const _RefreshFailedException(this.message);
  @override
  String toString() => message;
}