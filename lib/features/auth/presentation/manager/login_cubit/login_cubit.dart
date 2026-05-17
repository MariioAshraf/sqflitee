import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflitee/features/auth/presentation/manager/login_cubit/login_state.dart';

import '../../../../../core/services/token_service.dart';
import '../../../data/repositories/auth_repo.dart';

final class LoginCubit extends Cubit<LoginState> {
  final AuthRepo _authRepo;
  final TokenService _tokenService;

  LoginCubit({required AuthRepo authRepo, required TokenService tokenService})
    : _authRepo = authRepo,
      _tokenService = tokenService,
      super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());

    final result = await _authRepo.login(email: email, password: password);

    result.fold((failure) => emit(LoginFailure(failure)), (user) async {
      // نحفظ الـ role عشان الـ SplashCubit يقدر يقراه بعدين
      await _tokenService.saveUserRole(user.role.name);
      emit(LoginSuccess(user));
    });
  }

  Future<void> logout() async {
    await _tokenService.clearAll();
    emit(const LoginInitial());
  }
}
