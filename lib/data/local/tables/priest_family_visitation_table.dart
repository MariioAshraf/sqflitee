class PriestFamilyVisitationTable {
  static const String tableName = 'priest_family_visitations';

  static const String colId = 'id';
  static const String colFamilyId = 'family_id';
  static const String colPriestId = 'priest_id';
  static const String colVisitDate = 'visit_date';
  static const String colVisitationMethod = 'visitation_method';
  static const String colNotes = 'notes';

  // visitation_method values:
  // 1 = Home Visit
  // 2 = Phone Call
  // 3 = Electronic / Other

  static const String create = '''
    CREATE TABLE $tableName (
      $colId                  TEXT PRIMARY KEY,
      $colFamilyId            TEXT NOT NULL,
      $colPriestId            TEXT NOT NULL,
      $colVisitDate           TEXT NOT NULL DEFAULT (datetime('now')),
      $colVisitationMethod    INTEGER NOT NULL,
      $colNotes               TEXT,
      FOREIGN KEY ($colFamilyId) REFERENCES families(id) ON DELETE CASCADE,
      FOREIGN KEY ($colPriestId) REFERENCES users(id)
    )
  ''';
}
