abstract class TokenService {
  // Tokens
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  // Role
  Future<void> saveUserRole(String role);
  Future<String?> getUserRole();

  // Onboarding ✅
  Future<void> setOnboardingSeen();
  Future<bool> hasSeenOnboarding();

  // Clear
  Future<void> clearAll();
}