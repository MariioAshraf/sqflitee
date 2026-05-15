import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

abstract interface class AuthRepo {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}
