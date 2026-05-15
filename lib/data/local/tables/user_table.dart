class UserTable {
  static const create = '''
    CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        tenantId TEXT,
        email TEXT,
        password TEXT,
        phone TEXT,
        nationalId TEXT,
        role TEXT,
        isNeedToPostToServer INTEGER,
        createdAt TEXT,
        updatedAt TEXT,
        deletedAt TEXT
    )
  ''';
}
