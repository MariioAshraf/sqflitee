class AttendanceTable {
  static const String tableName = 'attendance';

  static const String colId = 'id';
  static const String colSessionId = 'session_id';
  static const String colUserId = 'user_id';
  static const String colStatusCode = 'status_code';
  static const String colNotes = 'notes';

  // status_code values:
  // 1 = Attended
  // 2 = Not Attended
  // 3 = Excused
  // 4 = Late

  static const String create = '''
    CREATE TABLE $tableName (
      $colId          TEXT PRIMARY KEY,
      $colSessionId   TEXT NOT NULL,
      $colUserId      TEXT NOT NULL,
      $colStatusCode  INTEGER NOT NULL CHECK ($colStatusCode BETWEEN 1 AND 4),
      $colNotes       TEXT,
      FOREIGN KEY ($colSessionId) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
      FOREIGN KEY ($colUserId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';
}
