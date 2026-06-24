import '../../../../../data/local/daos/user_dao.dart';
import '../../models/user_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserDao userDao;

  AuthLocalDataSourceImpl(this.userDao);

  @override
  Future<void> cacheUser(UserModel user) async {
    await userDao.cacheUser(user);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    return userDao.getUserByEmail(email);
  }
}
