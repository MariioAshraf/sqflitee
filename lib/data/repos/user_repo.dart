import '../../features/home/presentation/models/user.dart';
import '../local/dao/user_dao.dart';

class UserRepository {
  final UserDao dao;

  UserRepository(this.dao);

  Future<List<OldUserModel>> getUsers() => dao.getUsers();

  Future<OldUserModel> addUser(OldUserModel user) async {
    return await dao.insertUser(user);
  }

  Future<void> deleteUser(int id) => dao.deleteUser(id);

  Future<void> updateUser(OldUserModel user) => dao.updateUser(user);
}
