import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflitee/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:sqflitee/presentation/views/user_screen.dart';
import 'data/repos/user_repo.dart';
import 'di/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {


  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BlocProvider(
      create: (_) => UserCubit(getIt<UserRepository>())..loadUsers(),
      child: UserScreen(),
    ));
  }
}
