class ServantUserVisitationTable {
  static const String tableName = 'servant_user_visitations';

  static const String colId = 'id';
  static const String colTargetUserId = 'target_user_id';
  static const String colServantId = 'servant_id';
  static const String colClassId = 'class_id';
  static const String colVisitDate = 'visit_date';
  static const String colVisitationMethod = 'visitation_method';
  static const String colNotes = 'notes';

  // visitation_method values:
  // 1 = Home Visit
  // 2 = Phone Call
  // 3 = Other

  static const String create = '''
    CREATE TABLE $tableName (
      $colId                  TEXT PRIMARY KEY,
      $colTargetUserId        TEXT NOT NULL,
      $colServantId           TEXT NOT NULL,
      $colClassId             TEXT NOT NULL,
      $colVisitDate           TEXT NOT NULL DEFAULT (datetime('now')),
      $colVisitationMethod    INTEGER NOT NULL,
      $colNotes               TEXT,
      FOREIGN KEY ($colTargetUserId) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY ($colServantId) REFERENCES users(id),
      FOREIGN KEY ($colClassId) REFERENCES classes(id)
    )
  ''';
}
