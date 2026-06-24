class FamilyNoteTable {
  static const String tableName = 'family_notes';

  static const String colId = 'id';
  static const String colAuthorId = 'author_id';
  static const String colTargetFamilyId = 'target_family_id';
  static const String colNote = 'note';
  static const String colIsSecretNote = 'is_secret_note';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId                TEXT PRIMARY KEY,
      $colAuthorId          TEXT NOT NULL,
      $colTargetFamilyId    TEXT NOT NULL,
      $colNote              TEXT NOT NULL,
      $colIsSecretNote      INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt         TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt         TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY ($colAuthorId) REFERENCES users(id),
      FOREIGN KEY ($colTargetFamilyId) REFERENCES families(id) ON DELETE CASCADE
    )
  ''';
}
