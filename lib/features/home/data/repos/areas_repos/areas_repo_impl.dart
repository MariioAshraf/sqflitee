import 'package:dartz/dartz.dart';
import 'package:sqflitee/core/services/session_service.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../../core/services/sync_meta_service.dart';
import '../../../../../data/local/daos/area_dao.dart';
import '../../data_sources/areas_remote_data_source/areas_remote_data_source.dart';
import '../../models/area_model.dart';
import 'areas_repo.dart';

final class AreasRepoImpl implements AreasRepo {
  final AreasRemoteDataSource _remote;
  final AreaDao _areaDao;
  final SyncMetaService _syncMeta;
  final ConnectivityService _connectivity;
  final SessionService _sessionService;

  const AreasRepoImpl({
    required SessionService sessionService,
    required AreasRemoteDataSource remote,
    required AreaDao areaDao,
    required SyncMetaService syncMeta,
    required ConnectivityService connectivity,
  }) : _remote = remote,
       _sessionService = sessionService,
       _areaDao = areaDao,
       _syncMeta = syncMeta,
       _connectivity = connectivity;

  @override
  Future<Either<Failure, List<AreaModel>>> getLocalAreas() async {
    try {
      final areas = await _areaDao.getAll(tenantId: _sessionService.tenantId!);
      return Right(areas);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AreaModel>> createAreaLocally({
    required String name,
  }) async {
    try {
      final area = AreaModel.createLocal(
        tenantId: _sessionService.tenantId!,
        name: name,
      );
      await _areaDao.insertOrReplace(area);
      return Right(area);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ── Post Sync — برفع كل الـ pending ─────────────────────────
  @override
  Future<Either<Failure, void>> syncPendingAreas() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (!isConnected) return const Left(NoInternetFailure());

    try {
      final pending = await _areaDao.getPendingSync();
      if (pending.isEmpty) return const Right(null);
      final result = await _remote.postSyncAreas(areas: pending);
      await _areaDao.insertOrReplaceAll(result.records);
      await _syncMeta.setAreasLastPostSyncDate(result.lastSyncDate);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }


  @override
  Future<Either<Failure, void>> pullAreasFromServer() async {
    final isConnected = await _connectivity.checkConnectivity();
    if (!isConnected) return const Left(NoInternetFailure());
    try {
      final lastSyncDate = await _syncMeta.getAreasLastGetSyncDate();
      final result = await _remote.getSyncAreas(lastSyncDate: lastSyncDate);
      if (result.records.isNotEmpty) {
        await _areaDao.insertOrReplaceAll(result.records);
      }
      await _syncMeta.setAreasLastGetSyncDate(result.lastSyncDate);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(_mapToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapToFailure(NetworkException e) => switch (e.type) {
    NetworkExceptionType.noInternet => const NoInternetFailure(),
    NetworkExceptionType.unauthorized => const UnauthorizedFailure(),
    NetworkExceptionType.timeout => const TimeoutFailure(),
    NetworkExceptionType.serverError => ServerFailure(
      message: e.message,
      statusCode: e.statusCode,
    ),
    _ => UnknownFailure(message: e.message),
  };
}
