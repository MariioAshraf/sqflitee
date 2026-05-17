sealed class Failure {
  final String message;

  const Failure(this.message);
}

final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode})
    : super(message);
}

final class OfflineUserNotFoundFailure extends Failure {
  const OfflineUserNotFoundFailure()
    : super(
        'You are offline and there is local user found!, please connect to internet and try again later.',
      );
}

// test local access
final class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('No internet connection.');
}

// test local access
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Error, Login with invalid credentials.');
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Unauthorized. Please login again.');
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure() : super('You don\'t have permission.');
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('Resource not found.');
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}

final class RateLimitedFailure extends Failure {
  const RateLimitedFailure() : super('Too many requests. Please slow down.');
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Request timed out. Please try again.');
}

final class CancelledFailure extends Failure {
  const CancelledFailure() : super('Request was cancelled.');
}

final class BadCertificateFailure extends Failure {
  const BadCertificateFailure() : super('SSL certificate error.');
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message);
}
