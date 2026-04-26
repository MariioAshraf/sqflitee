import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflitee/data/local/tables/user_table.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(UserTable.create);

        await db.execute('''
    CREATE TABLE services (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

        await db.execute('''
    CREATE TABLE classes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      serviceId INTEGER,
      FOREIGN KEY (serviceId) REFERENCES services(id)
    )
  ''');

        await db.execute('''
    CREATE TABLE user_service_roles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      serviceId INTEGER,
      role TEXT,
      FOREIGN KEY (userId) REFERENCES users(id),
      FOREIGN KEY (serviceId) REFERENCES services(id)
    )
  ''');

        await db.execute('''
    CREATE TABLE user_class_roles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      classId INTEGER,
      role TEXT,
      FOREIGN KEY (userId) REFERENCES users(id),
      FOREIGN KEY (classId) REFERENCES classes(id)
    )
  ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 🔹 v2
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE users ADD COLUMN nationalId TEXT");
        }

        // 🔹 v3
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE users ADD COLUMN age INTEGER");
        }

        // 🔹 v4 (الجديد 🔥)
        if (oldVersion < 4) {
          // services
          await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

          // classes
          await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        serviceId INTEGER,
        FOREIGN KEY (serviceId) REFERENCES services(id)
      )
    ''');

          // user roles on service level
          await db.execute('''
      CREATE TABLE user_service_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        serviceId INTEGER,
        role TEXT,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (serviceId) REFERENCES services(id)
      )
    ''');

          // user roles on class level
          await db.execute('''
      CREATE TABLE user_class_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        classId INTEGER,
        role TEXT,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (classId) REFERENCES classes(id)
      )
    ''');
        }
      },
    );
  }
}
