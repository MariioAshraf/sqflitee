class AreaTable {
  static const String tableName = 'areas';
  static const String colId = 'id';
  static const String colTenantId = 'tenant_id';
  static const String colName = 'name';
  static const String colResponsiblePriestId = 'responsible_priest_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';
  static const String colIsNeedToPostSync = 'is_need_to_post_sync';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId                    TEXT PRIMARY KEY,
      $colTenantId              TEXT NOT NULL,
      $colName                  TEXT NOT NULL,
      $colResponsiblePriestId   TEXT,
      $colCreatedAt             TEXT NOT NULL,
      $colUpdatedAt             TEXT NOT NULL,
      $colDeletedAt             TEXT,
      $colIsNeedToPostSync      INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colTenantId) REFERENCES tenants(id) ON DELETE CASCADE,
      FOREIGN KEY ($colResponsiblePriestId) REFERENCES users(id)
    )
  ''';
}