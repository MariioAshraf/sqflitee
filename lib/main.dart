import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflitee/core/utils/bloc_observer.dart';
import 'package:sqflitee/features/auth/domain/entities/user_entity.dart';

import 'core/di/dependency_injection.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity/cubit/connectivity_cubit.dart';
import 'core/services/connectivity/cubit/connectivity_state.dart';
import 'core/services/token_service.dart';
import 'core/utils/connectivity_toast.dart';
import 'data/local/daos/user_dao.dart';
import 'data/local/db/app_data_base.dart';
import 'features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityCubit>(
      create: (_) => getIt<ConnectivityCubit>(),
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listenWhen: (previous, current) {
          if (previous.isInitial && current.isConnected) return false;
          return !current.isInitial;
        },
        listener: (_, state) {
          ConnectivityToast.show(isConnected: state.isConnected);
        },
        child: MaterialApp.router(
          title: 'Church App',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          // ✅ ربط الـ navigatorKey
        ),
      ),
    );
  }
}
