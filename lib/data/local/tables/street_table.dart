class StreetTable {
  static const String tableName = 'streets';

  // ── Column names ──────────────────────────────────────

  static const String colId = 'id';
  static const String colAreaId = 'area_id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colDeletedAt = 'deleted_at';
  static const String colIsNeedToPostSync = 'is_need_to_post_sync';

  static const String create =
      '''
    CREATE TABLE $tableName (
      $colId      TEXT PRIMARY KEY,
      $colAreaId  TEXT NOT NULL,
      $colName    TEXT NOT NULL,
      $colCreatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt   TEXT NOT NULL DEFAULT (datetime('now')),
      $colDeletedAt   TEXT,
      $colIsNeedToPostSync      INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colAreaId) REFERENCES areas(id) ON DELETE CASCADE
    )
  ''';
}
