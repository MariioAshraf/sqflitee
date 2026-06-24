class FamilyMemberTable {
  static const String tableName = 'family_members';

  static const String colId = 'id';
  static const String colFamilyId = 'family_id';
  static const String colUserId = 'user_id';
  static const String colMemberRole = 'member_role';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId          TEXT PRIMARY KEY,
      $colFamilyId    TEXT NOT NULL,
      $colUserId      TEXT NOT NULL,
      $colMemberRole  TEXT NOT NULL,
      FOREIGN KEY ($colFamilyId) REFERENCES families(id) ON DELETE CASCADE,
      FOREIGN KEY ($colUserId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';
}
