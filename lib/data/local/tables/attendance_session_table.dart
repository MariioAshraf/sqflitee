class AttendanceSessionTable {
  static const String tableName = 'attendance_sessions';

  static const String colId = 'id';
  static const String colClassId = 'class_id';
  static const String colRecordedBy = 'recorded_by';
  static const String colSessionDate = 'session_date';
  static const String colSessionType = 'session_type';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId            TEXT PRIMARY KEY,
      $colClassId       TEXT NOT NULL,
      $colRecordedBy    TEXT NOT NULL,
      $colSessionDate   TEXT NOT NULL DEFAULT (datetime('now')),
      $colSessionType   TEXT NOT NULL,
      FOREIGN KEY ($colClassId) REFERENCES classes(id) ON DELETE CASCADE,
      FOREIGN KEY ($colRecordedBy) REFERENCES users(id)
    )
  ''';
}
