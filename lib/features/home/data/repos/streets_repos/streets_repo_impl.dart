import 'package:dartz/dartz.dart';
import 'package:sqflitee/features/home/data/repos/streets_repos/streets_repo.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../../core/services/sync_meta_service.dart';
import '../../../../../data/local/daos/street_dao.dart';
import '../../data_sources/streets_remote_date_source/streets_remote_data_source.dart';
import '../../models/street_model.dart';

final class StreetsRepoImpl implements StreetsRepo {
  final StreetsRemoteDataSource _remote;
  final StreetDao               _streetDao;
  final SyncMetaService         _syncMeta;
  final ConnectivityService     _connectivity;

  const StreetsRepoImpl({
    required StreetsRemoteDataSource remote,
    required StreetDao streetDao,
    required SyncMetaService syncMeta,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _streetDao = streetDao,
        _syncMeta = syncMeta,
        _connectivity = connectivity;

  @override
  Future<Either<Failure, List<StreetModel>>> getLocalStreets({
    required String areaId,
  }) async {
    try {
      final streets = await _streetDao.getByAreaId(areaId);
      return Right(streets);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StreetModel>> createStreetLocally({
    required String areaId,
    required String name,
  }) async {
    try {
      final street = StreetModel.createLocal(areaId: areaId, name: name);
      await _streetDao.insertOrReplace(street);
      return Right(street);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingStreets() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (!isConnected) return const Left(NoInternetFailure());

    try {
      final pending = await _streetDao.getPendingSync();
      if (pending.isEmpty) return const Right(null);

      final result = await _remote.postSyncStreets(streets: pending);
      await _streetDao.insertOrReplaceAll(result.records);
      await _syncMeta.setStreetsLastPostSyncDate(result.lastSyncDate);

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pullStreetsFromServer() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (!isConnected) return const Left(NoInternetFailure());

    try {
      final lastSyncDate = await _syncMeta.getStreetsLastGetSyncDate();
      final result = await _remote.getSyncStreets(lastSyncDate: lastSyncDate);

      if (result.records.isNotEmpty) {
        await _streetDao.insertOrReplaceAll(result.records);
      }

      await _syncMeta.setStreetsLastGetSyncDate(result.lastSyncDate);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapToFailure(NetworkException e) => switch (e.type) {
    NetworkExceptionType.noInternet   => const NoInternetFailure(),
    NetworkExceptionType.unauthorized => const UnauthorizedFailure(),
    NetworkExceptionType.timeout      => const TimeoutFailure(),
    NetworkExceptionType.serverError  => ServerFailure(message: e.message, statusCode: e.statusCode),
    _                                 => UnknownFailure(message: e.message),
  };
}