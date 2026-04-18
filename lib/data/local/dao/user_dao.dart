import 'package:sqflite/sqflite.dart';
import 'package:sqflitee/data/local/db/data_base_tables.dart';

import '../../../models/user.dart';

class UserDao {
  final Database db;

  UserDao(this.db);

  // ➕ Add
  Future<int> insertUser(User user) async {
    return await db.insert(DbTables.users, user.toMap());
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
    return await db.delete(
      DbTables.users,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}