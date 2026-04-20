import 'package:sqflite/sqflite.dart';
import 'package:sqflitee/data/local/db/data_base_tables.dart';

import '../../../presentation/models/user.dart';

class UserDao {
  final Database db;

  UserDao(this.db);

  // ➕ Add
  Future<User> insertUser(User user) async {
    final id = await db.insert(DbTables.users, user.toMap());

    return User(id: id, name: user.name, email: user.email);
  }

  // 📥 Get all
  Future<List<User>> getUsers() async {
    final result = await db.query(DbTables.users);
    return result.map((e) => User.fromMap(e)).toList();
  }

  // ✏️ Update
  Future<int> updateUser(User user) async {
    return await db.update(
      DbTables.users,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ❌ Delete
  Future<int> deleteUser(int id) async {
    return await db.delete(DbTables.users, where: 'id = ?', whereArgs: [id]);
  }
}
