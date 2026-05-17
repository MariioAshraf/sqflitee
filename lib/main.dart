import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflitee/core/utils/bloc_observer.dart';
import 'package:sqflitee/features/auth/domain/entities/user_entity.dart';

import 'core/di/dependency_injection.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity/cubit/connectivity_cubit.dart';
import 'core/services/connectivity/cubit/connectivity_state.dart';
import 'core/services/token_service.dart';
import 'data/local/dao/user_dao.dart';
import 'data/local/db/app_data_base.dart';
import 'features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  // await seedAuthSession();
  // await seedTestUser();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

// Future<void> seedAuthSession() async {
//   final tokenService = getIt<TokenService>();
//
//   await tokenService.saveAccessToken('fake_access_token');
//
//   await tokenService.saveRefreshToken('fake_refresh_token');
//
//   await tokenService.saveUserRole('user');
//
//   print('AUTH SESSION SEEDED');
// }
//
// Future<void> seedTestUser() async {
//   final db = await AppDatabase.database;
//
//   final userDao = UserDao(db);
//
//   final existingUser = await userDao.getUserByEmail('mario@gmail.com');
//
//   if (existingUser != null) return;
//
//   await userDao.insertUser(
//     UserModel(
//       id: '123',
//       name: 'Mario',
//       tenantId: '55555',
//       email: 'mario@gmail.com',
//       phone: '01277075054',
//       nationalId: '30303010',
//       role: UserRole.user,
//       accessToken: 'local_access_token',
//       refreshToken: 'local_refresh_token',
//     ),
//   );
//
//   debugPrint('TEST USER INSERTED');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityCubit>(
      create: (_) => getIt<ConnectivityCubit>(),
      child: MaterialApp.router(
        title: 'Church App',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        builder: (context, child) =>
            BlocListener<ConnectivityCubit, ConnectivityState>(
              listenWhen: (previous, current) {
                if (previous.isInitial && current.isConnected) return false;
                return !current.isInitial;
              },
              listener: (context, state) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.isConnected
                          ? 'تم استعادة الاتصال'
                          : 'لا يوجد اتصال بالإنترنت',
                    ),
                    backgroundColor: state.isConnected
                        ? Colors.green
                        : Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: child ?? const SizedBox.shrink(),
            ),
      ),
    );
  }
}
