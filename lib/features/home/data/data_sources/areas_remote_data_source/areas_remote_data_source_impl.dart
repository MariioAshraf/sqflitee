import 'package:dio/dio.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../models/area_model.dart';
import 'areas_remote_data_source.dart';

final class AreasRemoteDataSourceImpl implements AreasRemoteDataSource {
  final ApiService _apiService;
  const AreasRemoteDataSourceImpl(this._apiService);

  @override
  Future<({List<AreaModel> records, String lastSyncDate})> getSyncAreas({
    required String? lastSyncDate,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.syncAreasEndpoint,
        queryParameters: lastSyncDate != null
            ? {'lastSyncDate': lastSyncDate}
            : null,
      );

      final data = response.data as Map<String, dynamic>;
      final records = (data['records'] as List<dynamic>)
          .map((e) => AreaModel.fromApi(e as Map<String, dynamic>))
          .toList();

      return (records: records, lastSyncDate: data['lastSyncDate'] as String);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<({List<AreaModel> records, String lastSyncDate})> postSyncAreas({
    required List<AreaModel> areas,
  }) async {

    try {

      final response = await _apiService.post(
        ApiConstants.syncAreasEndpoint,
        data: {'records': areas.map((a) => a.toPostSyncMap()).toList()},
      );

      final data = response.data as Map<String, dynamic>;
      final records = (data['records'] as List<dynamic>)
          .map((e) => AreaModel.fromApi(e as Map<String, dynamic>))
          .toList();

      return (records: records, lastSyncDate: data['lastSyncDate'] as String);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }
}