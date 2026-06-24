class UserChurchRoleTable {

  static const String tableName = 'user_church_roles';
  static const String colId = 'id';
  static const String colTenantId = 'tenant_id';
  static const String colUserId = 'user_id';
  static const String colRoleId = 'role_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsDeleted = 'is_deleted';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId          TEXT PRIMARY KEY,
      $colTenantId    TEXT NOT NULL,
      $colUserId      TEXT NOT NULL,
      $colRoleId      TEXT NOT NULL,
      $colCreatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colIsDeleted   INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colTenantId) REFERENCES tenants(id) ON DELETE CASCADE,
      FOREIGN KEY ($colUserId) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY ($colRoleId) REFERENCES roles(id) ON DELETE CASCADE
    )
  ''';
}
