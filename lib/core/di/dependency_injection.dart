import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/local/dao/user_dao.dart';
import '../../data/local/db/app_data_base.dart';
import '../../data/repos/user_repo.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source_impl.dart';
import '../network/api_service.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_factory.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/connectivity/connectivity_service_impl.dart';
import '../services/connectivity/cubit/connectivity_cubit.dart';
import '../services/token_service.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  final db = await AppDatabase.database;

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      dio: getIt<Dio>(),
      tokenService: getIt<TokenService>(),
      authRemoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<Dio>(() => getIt<DioFactory>().createDio());
  getIt.registerLazySingleton<Database>(() => db);
  getIt.registerLazySingleton<UserDao>(() => UserDao(getIt()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));

  // Connectivity DI

  // External
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Services
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(getIt()),
  );

  // Cubits
  getIt.registerFactory<ConnectivityCubit>(() => ConnectivityCubit(getIt()));
}
