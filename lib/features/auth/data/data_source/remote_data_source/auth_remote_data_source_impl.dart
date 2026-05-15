import 'package:dio/dio.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_data_source.dart';


final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  const AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromMap(response.data!);

    } on DioException catch (e) {
      // ✅ هنا بس — حول Dio لـ NetworkException
      throw NetworkException.fromError(e);

    } catch (e) {
      // أي حاجة تانية غير متوقعة
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<UserModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      return UserModel.fromMap(response.data!);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }

}