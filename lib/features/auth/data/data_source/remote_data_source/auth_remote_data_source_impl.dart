import 'package:dio/dio.dart';
import 'package:sqflitee/features/auth/data/models/signup_request_model.dart';
import 'package:sqflitee/features/auth/domain/use_cases/signup_params.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/signup_params.dart';
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
      final Map<String, dynamic> responseAsUser = {
        'id': '100',
        'name': 'mario',
        'tenantId': '50',
        'email': 'mario@gmail.com',
        'phone': '01277075054',
        'nationalId': '301090126',
        'role': 'user',
        'accessToken': 'accessToken',
        'refreshToken': 'refreshToken',
      };
      final Map<String, dynamic> responseAsPriest = {
        'id': '100',
        'name': 'mario',
        'tenantId': '50',
        'email': 'mario@gmail.com',
        'phone': '01277075054',
        'nationalId': '301090126',
        'role': 'priest',
        'accessToken': 'accessToken',
        'refreshToken': 'refreshToken',
      };

      // final response = await _apiService.post(
      //   ApiConstants.loginEndpoint,
      //   data: {'email': email, 'password': password},
      // );
      return UserModel.fromApi(responseAsPriest);
    } on DioException catch (e) {
      // ✅ هنا بس — حول Dio لـ NetworkException
      throw NetworkException.fromError(e);
    } catch (e) {
      // أي حاجة تانية غير متوقعة
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<UserModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      return UserModel.fromApi(response.data!);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<void> signUp({required SignUpParams params}) async {
    try {
      final Map<String, dynamic> responseAsUser = {
        'name': 'mario',
        'email': 'mario@gmail.com',
        'phone': '01277075054',
        'nationalId': '301090126',
        'password': '111',
      };
      // final request = SignUpRequestModel.fromParams(params);
      // final response = await _apiService.post(
      //   ApiConstants.signUpEndpoint,
      //   data: request.toMap(),
      // );
      // return UserModel.fromApi(response.data!);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }
}
