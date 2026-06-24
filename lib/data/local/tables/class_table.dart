class ClassTable {
  static const String tableName = 'classes';

  static const String colId = 'id';
  static const String colServiceId = 'service_id';
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colTracksMeeting = 'tracks_meeting';
  static const String colTracksKodas = 'tracks_kodas';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsDeleted = 'is_deleted';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId              TEXT PRIMARY KEY,
      $colServiceId       TEXT NOT NULL,
      $colName            TEXT NOT NULL,
      $colDescription     TEXT,
      $colTracksMeeting   INTEGER NOT NULL DEFAULT 1,
      $colTracksKodas     INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt       TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt       TEXT NOT NULL DEFAULT (datetime('now')),
      $colIsDeleted       INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colServiceId) REFERENCES services(id) ON DELETE CASCADE
    )
  ''';
}
