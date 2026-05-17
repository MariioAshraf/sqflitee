import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflitee/data/local/dao/user_dao.dart';
import '../../data/local/db/app_data_base.dart';
import '../../features/auth/data/data_source/local_data_source/auth_local_data_source.dart';
import '../../features/auth/data/data_source/local_data_source/auth_local_data_source_impl.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source_impl.dart';

import '../../features/auth/data/repositories/auth_repo_impl.dart';
import '../../features/auth/domain/repos/auth_repo.dart';
import '../../features/auth/presentation/manager/login_cubit/login_cubit.dart';
import '../../features/auth/presentation/manager/signup_cubit/sign_up_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../network/api_service.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_factory.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/connectivity/connectivity_service_impl.dart';
import '../services/connectivity/cubit/connectivity_cubit.dart';
import '../services/token_service.dart';
import '../services/token_service_impl.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  await _registerExternal();
  _registerServices();
  _registerNetwork();
  _registerDataSources();
  _registerRepos();
  _registerCubits();
}

// ── 1. External ───────────────────────────────────────────────────────────────
Future<void> _registerExternal() async {
  final db = await AppDatabase.database;

  getIt.registerLazySingleton<Database>(() => db);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
}

// ── 2. Services ───────────────────────────────────────────────────────────────
void _registerServices() {
  getIt.registerLazySingleton<TokenService>(
    () => TokenServiceImpl(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(getIt<Connectivity>()),
  );
}

// ── 3. Network ────────────────────────────────────────────────────────────────
// الترتيب هنا مهم جداً عشان نتجنب الـ infinite loop في الـ token refresh
void _registerNetwork() {
  // 3a. Dio نظيف — من غير AuthInterceptor
  //     الـ AuthRemoteDataSource هيستخدمه مباشرة
  //     عشان refresh token call ميعديش على AuthInterceptor
  getIt.registerLazySingleton<Dio>(() => DioFactory.create());

  // 3b. AuthRemoteDataSource بالـ Dio النظيف
  //     لازم يتسجل هنا قبل AuthInterceptor
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(ApiService(getIt<Dio>())),
  );
  ///////////////////////////////// test/////////////////////////////////////////////////
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(UserDao(getIt<Database>())),
  );

  // 3c. AuthInterceptor
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      dio: getIt<Dio>(),
      tokenService: getIt<TokenService>(),
      authRemoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // 3d. ApiService — بيضيف AuthInterceptor على الـ Dio
  //     كل الـ repos هتستخدم ApiService ده
  getIt.registerLazySingleton<ApiService>(() {
    final dio = getIt<Dio>();
    dio.interceptors.add(getIt<AuthInterceptor>());
    return ApiService(dio);
  });
}

// ── 4. Data Sources ───────────────────────────────────────────────────────────
void _registerDataSources() {
  // AuthRemoteDataSource اتسجل في _registerNetwork عشان محتاجه الـ interceptor
  // لو عندك data sources تانية بتستخدم ApiService بالـ auth interceptor ضيفها هنا
}

// ── 5. Repos ──────────────────────────────────────────────────────────────────
// void _registerRepos() {
//   getIt.registerLazySingleton<AuthRepo>(
//         () => AuthRepoImpl(
//       remoteDataSource: getIt<AuthRemoteDataSource>(),
//       connectivityService: getIt<ConnectivityService>(),
//       tokenService: getIt<TokenService>(),
//     ),
//   );
// }
void _registerRepos() {
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      localDataSource: getIt<AuthLocalDataSource>(),
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      tokenService: getIt<TokenService>(),
    ),
  );
}

// ── 6. Cubits ─────────────────────────────────────────────────────────────────
void _registerCubits() {
  // factory — مش singleton عشان BlocProvider بيتحكم في الـ lifecycle
  getIt.registerFactory<ConnectivityCubit>(
    () => ConnectivityCubit(getIt<ConnectivityService>()),
  );
  getIt.registerFactory<SignUpCubit>(
    () => SignUpCubit(authRepo: getIt<AuthRepo>()),
  );
  getIt.registerFactory<SplashCubit>(() => SplashCubit(getIt<TokenService>()));
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      authRepo: getIt<AuthRepo>(),
      tokenService: getIt<TokenService>(),
    ),
  );
}
