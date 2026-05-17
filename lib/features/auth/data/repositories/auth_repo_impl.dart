import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:sqflitee/features/auth/data/data_source/local_data_sourcec/auth_local_data_source.dart';
import 'package:sqflitee/features/auth/data/models/user_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/user_entity.dart';
import '../data_source/remote_data_source/auth_remote_data_source.dart';
import 'auth_repo.dart';

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
  }) async {
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      return _handleOfflineLogin(email: email, password: password);
    }

    return _handleOnlineLogin(email: email, password: password);
  }

  // ── Offline ───────────────────────────────────────────
  Future<Either<Failure, UserEntity>> _handleOfflineLogin({
    required String email,
    required String password,
  }) async {
    final cachedUser = await localDataSource.getUserByEmail(email);

    if (cachedUser == null) {
      return const Left(NoInternetFailure());
    }

    if (!cachedUser.verifyPassword(password)) {
      return const Left(InvalidCredentialsFailure());
    }

    return Right(cachedUser);
  }

  // ── Online ────────────────────────────────────────────
  Future<Either<Failure, UserEntity>> _handleOnlineLogin({
    required String email,
    required String password,
  }) async {
    try {
      final cachedUser = await localDataSource.getUserByEmail(email);

      /// if user already exists wake sure of credentials, then update tokens.
      if (cachedUser != null) {
        if (!cachedUser.verifyPassword(password)) {

          return const Left(InvalidCredentialsFailure());
        }
        unawaited(_refreshAndCache(email: email, password: password));
        return Right(cachedUser);
      }

      /// here means that the user is logging for first time, so login and save data.
      return _loginFromApi(email: email, password: password);
    } on NetworkException catch (e) {
      return Left(_mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Background refresh ────────────────────────────────────────
  Future<void> _refreshAndCache({
    required String email,
    required String password,
  }) async {
    try {
      final freshUser = await remoteDataSource.login(
        email: email,
        password: password,
      ); // freshUser → UserModel من الـ API (من غير passwordHash)

      final userToCache = freshUser.withHashedPassword(password);

      await Future.wait([
        tokenService.saveAccessToken(freshUser.accessToken),
        tokenService.saveRefreshToken(freshUser.refreshToken),
        tokenService.saveUserRole(freshUser.role.toJson()),
        localDataSource.cacheUser(userToCache),
      ]);
    } catch (_) {
      // background فشل — مش مشكلة
    }
  }

  // ── First login ───────────────────────────────────────────────
  Future<Either<Failure, UserEntity>> _loginFromApi({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      final userToCache = user.withHashedPassword(password);

      await Future.wait([
        tokenService.saveAccessToken(user.accessToken),
        tokenService.saveRefreshToken(user.refreshToken),
        tokenService.saveUserRole(user.role.toJson()),
        localDataSource.cacheUser(userToCache),
      ]);

      return Right(user);
    } on NetworkException catch (e) {
      return Left(_mapNetworkExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapNetworkExceptionToFailure(NetworkException e) {
    return switch (e.type) {
      NetworkExceptionType.noInternet => const NoInternetFailure(),
      NetworkExceptionType.unauthorized => const UnauthorizedFailure(),
      NetworkExceptionType.forbidden => const ForbiddenFailure(),
      NetworkExceptionType.notFound => const NotFoundFailure(),
      NetworkExceptionType.validationError => ValidationFailure(
        message: e.message,
      ),
      NetworkExceptionType.rateLimited => const RateLimitedFailure(),
      NetworkExceptionType.serverError => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      NetworkExceptionType.timeout => const TimeoutFailure(),
      NetworkExceptionType.cancelled => const CancelledFailure(),
      NetworkExceptionType.badCertificate => const BadCertificateFailure(),
      NetworkExceptionType.unknown => UnknownFailure(message: e.message),
    };
  }
}
