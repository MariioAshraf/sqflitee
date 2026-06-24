import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflitee/data/local/daos/street_dao.dart';
import 'package:sqflitee/data/local/daos/user_dao.dart';
import 'package:sqflitee/data/local/daos/area_dao.dart';
import 'package:sqflitee/features/home/data/data_sources/streets_remote_date_source/streets_remote_data_source.dart';
import 'package:sqflitee/features/home/data/repos/streets_repos/streets_repo.dart';
import 'package:sqflitee/features/home/data/repos/streets_repos/streets_repo_impl.dart';
import 'package:sqflitee/features/home/presentation/cubits/manage_areas_cubit/areas_cubit.dart';
import '../../data/local/db/app_data_base.dart';
import '../../features/auth/data/data_source/local_data_source/auth_local_data_source.dart';
import '../../features/auth/data/data_source/local_data_source/auth_local_data_source_impl.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../../features/auth/data/data_source/remote_data_source/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repo_impl.dart';
import '../../features/auth/domain/repos/auth_repo.dart';
import '../../features/auth/presentation/manager/login_cubit/login_cubit.dart';
import '../../features/auth/presentation/manager/signup_cubit/sign_up_cubit.dart';
import '../../features/home/data/data_sources/areas_remote_data_source/areas_remote_data_source.dart';
import '../../features/home/data/data_sources/areas_remote_data_source/areas_remote_data_source_impl.dart';
import '../../features/home/data/data_sources/streets_remote_date_source/streets_remote_data_source_impl.dart';
import '../../features/home/data/repos/areas_repos/areas_repo.dart';
import '../../features/home/data/repos/areas_repos/areas_repo_impl.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../network/api_service.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_factory.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/connectivity/connectivity_service_impl.dart';
import '../services/connectivity/cubit/connectivity_cubit.dart';
import '../services/session_service.dart';
import '../services/sync_meta_service.dart';
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

// ── 1. External ─────────────────────────────────────────────────────────────
Future<void> _registerExternal() async {
  final db = await AppDatabase.database;
  final prefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<Database>(() => db);
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
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
  getIt.registerLazySingleton<SyncMetaService>(
    () => SyncMetaService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<SessionService>(() => SessionService());
}

// ── 3. Network ────────────────────────────────────────────────────────────────
// الترتيب هنا مهم جداً عشان نتجنب الـ infinite loop في الـ token refresh
void _registerNetwork() {
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      tokenService: getIt<TokenService>(),
      authRemoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<Dio>(() {
    final dio = DioFactory.create();
    final interceptor = getIt<AuthInterceptor>();
    interceptor.dio = dio; // ✅ نربطهم بعد الإنشاء — مفيش circular
    dio.interceptors.add(interceptor);
    return dio;
  });

  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  // Dio منفصل للـ AuthRemoteDataSource — بدون AuthInterceptor خالص
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      ApiService(DioFactory.create()),
      getIt<TokenService>(),
    ),
  );
}

// ── 4. Data Sources ───────────────────────────────────────────────────────────
void _registerDataSources() {
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(UserDao(getIt<Database>())),
  );

  getIt.registerLazySingleton<AreasRemoteDataSource>(
    () => AreasRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<StreetsRemoteDataSource>(
    () => StreetsRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // ── DAOs ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AreaDao>(() => AreaDao(getIt<Database>()));
  getIt.registerLazySingleton<StreetDao>(() => StreetDao(getIt<Database>()));
}

// ── 5. Repos ──────────────────────────────────────────────────────────────────
void _registerRepos() {

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      localDataSource: getIt<AuthLocalDataSource>(),
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      connectivityService: getIt<ConnectivityService>(),
      tokenService: getIt<TokenService>(),
    ),
  );
  getIt.registerLazySingleton<AreasRepo>(
        () => AreasRepoImpl(
      sessionService: getIt<SessionService>(),
      remote: getIt<AreasRemoteDataSource>(),
      areaDao: getIt<AreaDao>(),
      syncMeta: getIt<SyncMetaService>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );
  getIt.registerLazySingleton<StreetsRepo>(
    () => StreetsRepoImpl(
      streetDao: getIt<StreetDao>(),
      syncMeta: getIt<SyncMetaService>(),
      remote: getIt<StreetsRemoteDataSource>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );


}

// ── 6. Cubits ─────────────────────────────────────────────────────────────────
void _registerCubits() {
  // factory — مش singleton عشان BlocProvider بيتحكم في الـ lifecycle
  getIt.registerFactory<ConnectivityCubit>(
    () => ConnectivityCubit(getIt<ConnectivityService>()),
  );

  getIt.registerFactory<AreasCubit>(
    () => AreasCubit(
      areasRepo: getIt<AreasRepo>(),
      streetDao: getIt<StreetDao>(),
      streetsRepo: getIt<StreetsRepo>(),
    )..loadAreas(),
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
