import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/connectivity/cubit/connectivity_cubit.dart';
import 'data/repos/user_repo.dart';
import 'features/home/presentation/cubit/user_cubit/user_cubit.dart';
import 'features/home/presentation/views/user_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityCubit>(
      create: (_) => getIt<ConnectivityCubit>(),
      child: MaterialApp(
        home: BlocProvider<UserCubit>(
          create: (_) => UserCubit(getIt<UserRepository>())..loadUsers(),
          child: UserScreen(),
        ),
      ),
    );
  }
}
