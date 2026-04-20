import '../../presentation/models/user.dart';
import '../local/dao/user_dao.dart';

class UserRepository {
  final UserDao dao;

  UserRepository(this.dao);

  Future<List<User>> getUsers() => dao.getUsers();

  Future<User> addUser(User user) async {
    return await dao.insertUser(user);
  }

  Future<void> deleteUser(int id) => dao.deleteUser(id);

  Future<void> updateUser(User user) => dao.updateUser(user);
}
