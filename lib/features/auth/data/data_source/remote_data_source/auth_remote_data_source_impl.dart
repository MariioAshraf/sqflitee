import 'package:dio/dio.dart';
import 'package:sqflitee/core/services/token_service.dart';
import 'package:sqflitee/features/auth/data/models/signup_request_model.dart';
import 'package:sqflitee/features/auth/domain/use_cases/signup_params.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_data_source.dart';

// ════════════════════════════════════════════════════════
//  AuthRemoteDataSourceImpl
//  مسؤوليته: API calls فقط + save tokens
// ════════════════════════════════════════════════════════
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;
  final TokenService _tokenService;

  const AuthRemoteDataSourceImpl(this._apiService, this._tokenService);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required String churchCode,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
          'churchCode': churchCode,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      // ✅ الـ tokens بتتخزن هنا — مسؤولية الـ data source
      await _tokenService.saveAccessToken(accessToken);
      await _tokenService.saveRefreshToken(refreshToken);

      return UserModel.fromApi(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<void> signUp({required SignUpParams params}) async {
    try {
      final request = SignUpRequestModel.fromParams(params);
      await _apiService.post(
        ApiConstants.signUpEndpoint,
        data: request.toMap(),
      );
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }
  // في AuthRemoteDataSourceImpl
  @override
  Future<void> refreshToken({required String refreshToken}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccessToken  = data['accessToken']  as String;
      final newRefreshToken = data['refreshToken'] as String;

      await _tokenService.saveAccessToken(newAccessToken);
      await _tokenService.saveRefreshToken(newRefreshToken);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }
}


