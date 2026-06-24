
import 'package:sqflitee/features/auth/data/models/user_model.dart';


final class SessionService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  String? get tenantId {
    print('tenantId ===================== ${_currentUser?.tenantId}');
    return 'b1cd112e-55b1-41db-86e3-6f760b41d78e';
    return _currentUser?.tenantId;
  }

  bool get isAuthenticated => _currentUser != null;

  void setUser(UserModel user) => _currentUser = user;

  void clear() => _currentUser = null;
}