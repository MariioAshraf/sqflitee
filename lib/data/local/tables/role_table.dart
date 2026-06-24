class RoleTable {
  static const String tableName = 'roles';

  static const String colId = 'id';
  static const String colName = 'name';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId    TEXT PRIMARY KEY,
      $colName  TEXT NOT NULL
    )
  ''';
}
