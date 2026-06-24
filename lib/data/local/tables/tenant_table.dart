class TenantTable {
  static const String tableName = 'tenants';

  // ── Column names ──────────────────────────────────────
  static const String colId        = 'id';
  static const String colName      = 'name';
  static const String colCode      = 'code';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';

  // ── JOIN aliases ──────────────────────────────────────
  // بنستخدمهم في UserDao عشان مفيش conflict مع users columns
  // مثلاً: users.id و tenants.id — الاتنين اسمهم id
  // فبنعمل alias للـ tenant columns: t_id, t_name, ...
  static const String colIdAlias        = 't_id';
  static const String colNameAlias      = 't_name';
  static const String colCodeAlias      = 't_code';
  static const String colCreatedAtAlias = 't_created_at';
  static const String colUpdatedAtAlias = 't_updated_at';
  static const String colDeletedAtAlias = 't_deleted_at';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId          TEXT PRIMARY KEY,
      $colName        TEXT NOT NULL,
      $colCode        TEXT NOT NULL UNIQUE,
      $colCreatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colDeletedAt   TEXT
    )
  ''';
}