import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../../data/repos/user_repo.dart';
import '../../models/user.dart';
part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repo;

  List<OldUserModel> users = [];

  UserCubit(this.repo) : super(UserInitial());

  Future<void> loadUsers() async {
    emit(UserLoading());
    users = await repo.getUsers();
    emit(UserLoaded(users));
  }

  Future<void> addUser(String name, String email) async {
    final newUser = await repo.addUser(OldUserModel(name: name, email: email));

    users.add(newUser); // 👈 بدون reload
    emit(UserLoaded(List.from(users)));
  }

  Future<void> deleteUser(int id) async {
    await repo.deleteUser(id);

    users.removeWhere((e) => e.id == id);
    emit(UserLoaded(List.from(users)));
  }

  Future<void> updateUser(OldUserModel updatedUser) async {
    await repo.updateUser(updatedUser);

    final index = users.indexWhere((e) => e.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser; // 👈 update local list
    }

    emit(UserLoaded(List.from(users)));
  }
}
