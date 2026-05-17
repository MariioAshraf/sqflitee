
import '../../../domain/use_cases/signup_params.dart';
import '../../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> refreshToken({
    required String refreshToken,
  });
  Future<void> signUp({
    required SignUpParams params,
  });
}