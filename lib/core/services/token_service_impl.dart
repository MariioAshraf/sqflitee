import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_service.dart';

class TokenServiceImpl implements TokenService {
  final FlutterSecureStorage secureStorage;

  TokenServiceImpl(this.secureStorage);

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  @override
  Future<void> saveAccessToken(String token) async {
    await secureStorage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(
      key: _refreshTokenKey,
      value: token,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clear() async {
    await secureStorage.deleteAll();
  }
}