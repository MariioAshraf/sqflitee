class UserTable {
  static const String tableName = 'users';

  // Column names كـ constants عشان متكتبش كـ String في كل حتة
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colTenantId = 'tenantId';
  static const String colEmail = 'email';
  static const String colPhone = 'phone';
  static const String colNationalId = 'nationalId';
  static const String colRole = 'role';
  static const String colAccessToken = 'accessToken';
  static const String colRefreshToken = 'refreshToken';
  static const String colPasswordHash = 'passwordHash'; // ← hash مش plain text

  static const String create =
      '''
    CREATE TABLE $tableName (
      $colId           TEXT PRIMARY KEY,
      $colName         TEXT NOT NULL,
      $colTenantId     TEXT NOT NULL,
      $colEmail        TEXT NOT NULL UNIQUE,
      $colPhone        TEXT NOT NULL,
      $colNationalId   TEXT NOT NULL,
      $colRole         TEXT NOT NULL,
      $colAccessToken  TEXT NOT NULL,
      $colRefreshToken TEXT NOT NULL,
      $colPasswordHash TEXT NOT NULL
    )
  ''';
}
