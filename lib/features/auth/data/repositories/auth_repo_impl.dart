import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../data/data_source/local_data_source/auth_local_data_source.dart';
import '../../data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repo.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/use_cases/signup_params.dart';

final class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final TokenService tokenService;

  const AuthRepoImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityService,
    required this.tokenService,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required String churchCode,
  }) async {
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      // ── Offline ──────────────────────────────────────
      final cachedUser = await localDataSource.getUserByEmail(email);

      if (cachedUser == null) return const Left(OfflineUserNotFoundFailure());

      // bcrypt verify مش ممكن client-side
      // لو الـ user موجود في الـ cache معناه دخل قبل كده
      return Right(cachedUser);
    }

    return _handleOnlineLogin(
      email: email,
      password: password,
      churchCode: churchCode,
    );
  }

  // ── Online ────────────────────────────────────────────
  Future<Either<Failure, UserEntity>> _handleOnlineLogin({
    required String email,
    required String password,
    required String churchCode,
  }) async {
    try {
      final cachedUser = await localDataSource.getUserByEmail(email);

      if (cachedUser != null) {
        // اليوزر موجود — رجّع الـ cache فوراً وجدّد في الـ background
        unawaited(
          _refreshAndCache(
            email: email,
            password: password,
            churchCode: churchCode,
          ),
        );
        return Right(cachedUser);
      }

      return _loginFromApi(
        email: email,
        password: password,
        churchCode: churchCode,
      );
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Background refresh ────────────────────────────────
  // tokens → data source
  // cache  → local data source
  Future<void> _refreshAndCache({
    required String email,
    required String password,
    required String churchCode,
  }) async {
    try {
      // remoteDataSource.login بيتكلم بالـ tokens تلقائياً
      final freshUser = await remoteDataSource.login(
        churchCode: churchCode,
        email: email,
        password: password,
      );

      // ✅ الـ repo مسؤول بس عن الـ role + cache
      await Future.wait([
        tokenService.saveUserRole(freshUser.userRole.apiValue),
        localDataSource.cacheUser(freshUser),
      ]);
    } catch (_) {
      // background فشل — مش مشكلة
    }
  }

  // ── First Login ───────────────────────────────────────
  Future<Either<Failure, UserEntity>> _loginFromApi({
    required String email,
    required String password,
    required String churchCode,
  }) async {
    try {
      // remoteDataSource.login بيتكلم بالـ tokens تلقائياً
      final user = await remoteDataSource.login(
        churchCode: churchCode,
        email: email,
        password: password,
      );

      // ✅ الـ repo مسؤول بس عن الـ role + cache + session
      await Future.wait([
        tokenService.saveUserRole(user.userRole.apiValue),
        localDataSource.cacheUser(user),
      ]);

      getIt<SessionService>().setUser(user);

      return Right(user);
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Sign Up ───────────────────────────────────────────
  @override
  Future<Either<Failure, void>> signUp({required SignUpParams params}) async {
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) return const Left(NoInternetFailure());

    try {
      await remoteDataSource.signUp(params: params);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Map ───────────────────────────────────────────────
  Failure _mapToFailure(NetworkException e) {
    return switch (e.type) {
      NetworkExceptionType.noInternet      => const NoInternetFailure(),
      NetworkExceptionType.unauthorized    => const UnauthorizedFailure(),
      NetworkExceptionType.forbidden       => const ForbiddenFailure(),
      NetworkExceptionType.notFound        => const NotFoundFailure(),
      NetworkExceptionType.validationError => ValidationFailure(message: e.message),
      NetworkExceptionType.rateLimited     => const RateLimitedFailure(),
      NetworkExceptionType.serverError     => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      NetworkExceptionType.timeout         => const TimeoutFailure(),
      NetworkExceptionType.cancelled       => const CancelledFailure(),
      NetworkExceptionType.badCertificate  => const BadCertificateFailure(),
      NetworkExceptionType.unknown         => UnknownFailure(message: e.message),
    };
  }
}