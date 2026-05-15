// lib/features/auth/data/data_source/auth_remote_data_source.dart


import '../../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> refreshToken({
    required String refreshToken,
  });
}