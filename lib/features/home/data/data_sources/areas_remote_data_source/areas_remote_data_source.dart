
import '../../models/area_model.dart';

abstract interface class AreasRemoteDataSource {
  Future<({List<AreaModel> records, String lastSyncDate})> getSyncAreas({
    required String? lastSyncDate,
  });

  Future<({List<AreaModel> records, String lastSyncDate})> postSyncAreas({
    required List<AreaModel> areas,
  });
}