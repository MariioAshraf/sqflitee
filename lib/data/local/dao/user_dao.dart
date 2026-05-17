import 'package:sqflite/sqflite.dart';
import 'package:sqflitee/data/local/db/data_base_tables.dart';
import 'package:sqflitee/features/auth/data/models/user_model.dart';



class UserDao {
  final Database db;

  UserDao(this.db);

  // ➕ Add
  Future<void> insertUser(UserModel user) async {
    await db.insert(
      DbTables.users,
      user.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<UserModel?> getUserByEmail(
      String email,
      ) async {

    final result = await db.query(
      DbTables.users,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return UserModel.fromDb(result.first);
  }
  // // 📥 Get all
  // Future<List<UserModel>> getUsers() async {
  //   final result = await db.query(DbTables.users);
  //   return result.map((e) => UserModel.fromMap(e)).toList();
  // }
  //
  // // ✏️ Update
  // Future<int> updateUser(UserModel user) async {
  //   return await db.update(
  //     DbTables.users,
  //     user.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [user.id],
  //   );
  // }

  // // ❌ Delete
  // Future<int> deleteUser(int id) async {
  //   return await db.delete(DbTables.users, where: 'id = ?', whereArgs: [id]);
  // }
}
