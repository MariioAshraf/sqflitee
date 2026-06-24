import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/local/daos/street_dao.dart';
import '../../../data/models/area_model.dart';
import '../../../data/models/area_with_streets_model.dart';
import '../../../data/repos/areas_repos/areas_repo.dart';
import '../../../data/repos/streets_repos/streets_repo.dart';
import 'areas_state.dart';

final class AreasCubit extends Cubit<AreasState> {
  final AreasRepo   _areasRepo;
  final StreetsRepo _streetsRepo;
  final StreetDao   _streetDao; // للـ grouped query

  AreasCubit({
    required AreasRepo areasRepo,
    required StreetsRepo streetsRepo,
    required StreetDao streetDao,
  })  : _areasRepo = areasRepo,
        _streetsRepo = streetsRepo,
        _streetDao = streetDao,
        super(const AreasInitial());

  Future<void> loadAreas() async {
    final localResult = await _areasRepo.getLocalAreas();

    await localResult.fold(
          (failure) async => emit(AreasFailure(failure.message)),
          (areas) async {
        final combined = await _combineAreasWithStreets(areas);
        emit(AreasLoaded(combined));
      },
    );

    unawaited(_syncInBackground());
  }

  Future<void> _syncInBackground() async {
    final current = state;
    if (current is! AreasLoaded) return;

    emit(current.copyWith(isSyncing: true));

    // ── الترتيب مهم: areas الأول لأن streets بتعتمد على areaId ─
    await _areasRepo.syncPendingAreas();
    await _areasRepo.pullAreasFromServer();
    await _streetsRepo.syncPendingStreets();
    await _streetsRepo.pullStreetsFromServer();

    final refreshed = await _areasRepo.getLocalAreas();
    await refreshed.fold(
          (_) async => emit(current.copyWith(isSyncing: false)),
          (areas) async {
        final combined = await _combineAreasWithStreets(areas);
        emit(AreasLoaded(combined, isSyncing: false));
      },
    );
  }

  Future<void> createArea({required String name}) async {
    final result = await _areasRepo.createAreaLocally(name: name);

    await result.fold(
          (failure) async => emit(AreasFailure(failure.message)),
          (newArea) async {
        final current = state;
        if (current is AreasLoaded) {
          emit(current.copyWith(
            areasWithStreets: [
              AreaWithStreets(area: newArea, streets: const []),
              ...current.areasWithStreets,
            ],
          ));
        } else {
          emit(AreasLoaded([
            AreaWithStreets(area: newArea, streets: const []),
          ]));
        }
        unawaited(_syncInBackground());
      },
    );
  }

  Future<void> createStreet({
    required String areaId,
    required String name,
  }) async {
    final result = await _streetsRepo.createStreetLocally(
      areaId: areaId,
      name: name,
    );

    await result.fold(
          (failure) async => emit(AreasFailure(failure.message)),
          (newStreet) async {
        final current = state;
        if (current is AreasLoaded) {
          final updated = current.areasWithStreets.map((aws) {
            if (aws.area.id == areaId) {
              return AreaWithStreets(
                area: aws.area,
                streets: [newStreet, ...aws.streets],
              );
            }
            return aws;
          }).toList();
          emit(current.copyWith(areasWithStreets: updated));
        }
        unawaited(_syncInBackground());
      },
    );
  }

  Future<List<AreaWithStreets>> _combineAreasWithStreets(
      List<AreaModel> areas,
      ) async {
    final areaIds = areas.map((a) => a.id).toList();
    final grouped  = await _streetDao.getGroupedByAreaIds(areaIds);

    return areas.map((area) {
      return AreaWithStreets(
        area: area,
        streets: grouped[area.id] ?? [],
      );
    }).toList();
  }

  Future<void> manualSync() => _syncInBackground();
}
