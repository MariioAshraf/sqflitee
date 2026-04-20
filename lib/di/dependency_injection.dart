import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import '../data/local/dao/user_dao.dart';
import '../data/local/db/app_data_base.dart';
import '../data/repos/user_repo.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  final db = await AppDatabase.database;

  getIt.registerLazySingleton<Database>(() => db);
  getIt.registerLazySingleton<UserDao>(() => UserDao(getIt()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));


}
