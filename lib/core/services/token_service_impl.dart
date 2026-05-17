import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_service.dart';

class TokenServiceImpl implements TokenService {
  final FlutterSecureStorage _storage;

  TokenServiceImpl(this._storage);

  // ── Keys ──────────────────────────────────────────────
  static const _accessTokenKey    = 'access_token';
  static const _refreshTokenKey   = 'refresh_token';
  static const _userRoleKey       = 'user_role';
  static const _onboardingKey     = 'has_seen_onboarding'; // ✅

  // ── Tokens ────────────────────────────────────────────
  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  @override
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  @override
  Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  // ── Role ──────────────────────────────────────────────
  @override
  Future<void> saveUserRole(String role) =>
      _storage.write(key: _userRoleKey, value: role);

  @override
  Future<String?> getUserRole() =>
      _storage.read(key: _userRoleKey);

  // ── Onboarding ✅ ─────────────────────────────────────
  @override
  Future<void> setOnboardingSeen() =>
      _storage.write(key: _onboardingKey, value: 'true');

  @override
  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  // ── Clear ─────────────────────────────────────────────
  @override
  Future<void> clearAll() => _storage.deleteAll();
}