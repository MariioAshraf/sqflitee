
import '../../models/street_model.dart';

abstract interface class StreetsRemoteDataSource {
  Future<({List<StreetModel> records, String lastSyncDate})> getSyncStreets({
    required String? lastSyncDate,
  });

  Future<({List<StreetModel> records, String lastSyncDate})> postSyncStreets({
    required List<StreetModel> streets,
  });
}