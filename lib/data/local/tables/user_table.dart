class UserTable {
  static const String tableName = 'users';

  static const String colId = 'id';
  static const String colTenantId = 'tenant_id';
  static const String colFullName = 'full_name';
  static const String colEmail = 'email';
  static const String colPasswordHash = 'password_hash';
  static const String colPhone = 'phone';
  static const String colNationalId = 'national_id';
  static const String colBirthDate = 'birth_date';
  static const String colQrCode = 'qr_code';
  static const String colPhotoPath = 'photo_path';
  static const String colBaptismDate = 'baptism_date';
  static const String colConfessionPriestId = 'confession_priest_id';
  static const String colUserRole = 'user_role';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId                  TEXT PRIMARY KEY,
      $colTenantId            TEXT NOT NULL,
      $colFullName            TEXT NOT NULL,
      $colEmail               TEXT UNIQUE,
      $colPasswordHash        TEXT,
      $colPhone               TEXT,
      $colNationalId          TEXT UNIQUE,
      $colBirthDate           TEXT,
      $colQrCode              TEXT UNIQUE,
      $colPhotoPath           TEXT,
      $colBaptismDate         TEXT,
      $colConfessionPriestId  TEXT,
      $colUserRole            TEXT NOT NULL,
      $colCreatedAt           TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt           TEXT NOT NULL DEFAULT (datetime('now')),
      $colDeletedAt           TEXT,
      FOREIGN KEY ($colTenantId) REFERENCES tenants(id) ON DELETE CASCADE,
      FOREIGN KEY ($colConfessionPriestId) REFERENCES users(id)
    )
  ''';
}