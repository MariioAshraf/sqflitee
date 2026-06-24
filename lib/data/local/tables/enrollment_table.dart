class EnrollmentTable {
  static const String tableName = 'enrollments';

  static const String colId = 'id';
  static const String colClassId = 'class_id';
  static const String colUserId = 'user_id';
  static const String colStatus = 'status';
  static const String colCreatedAt = 'created_at';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId        TEXT PRIMARY KEY,
      $colClassId   TEXT NOT NULL,
      $colUserId    TEXT NOT NULL,
      $colStatus    TEXT NOT NULL DEFAULT 'ACTIVE',
      $colCreatedAt TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY ($colClassId) REFERENCES classes(id) ON DELETE CASCADE,
      FOREIGN KEY ($colUserId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';
}
