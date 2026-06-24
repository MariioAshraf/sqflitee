class ServiceTable {
  static const String tableName = 'services';

  static const String colId = 'id';
  static const String colTenantId = 'tenant_id';
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsDeleted = 'is_deleted';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId          TEXT PRIMARY KEY,
      $colTenantId    TEXT NOT NULL,
      $colName        TEXT NOT NULL,
      $colDescription TEXT,
      $colCreatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colIsDeleted   INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colTenantId) REFERENCES tenants(id) ON DELETE CASCADE
    )
  ''';
}
