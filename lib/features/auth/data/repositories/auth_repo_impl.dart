import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/user_entity.dart';
import '../data_source/remote_data_source/auth_remote_data_source.dart';
import 'auth_repo.dart';

final class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final TokenService tokenService;

  const AuthRepoImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.tokenService,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    // 1️⃣ Connectivity — قبل أي حاجة
    final isConnected = await connectivityService.checkConnectivity();
    if (!isConnected) {
      return const Left(NoInternetFailure());
    }

    // 2️⃣ API Call
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // 3️⃣ Save tokens
      await Future.wait([
        tokenService.saveAccessToken(user.accessToken),
        tokenService.saveRefreshToken(user.refreshToken),
      ]);

      return Right(user);
    } on NetworkException catch (e) {
      return Left(_mapNetworkExceptionToFailure(e));
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
