import 'package:dio/dio.dart';
import 'package:sqflitee/features/home/data/data_sources/streets_remote_date_source/streets_remote_data_source.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../models/street_model.dart';

final class StreetsRemoteDataSourceImpl implements StreetsRemoteDataSource {
  final ApiService _apiService;
  const StreetsRemoteDataSourceImpl(this._apiService);

  @override
  Future<({List<StreetModel> records, String lastSyncDate})> getSyncStreets({
    required String? lastSyncDate,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.syncStreetsEndpoint,
        queryParameters: lastSyncDate != null
            ? {'lastSyncDate': lastSyncDate}
            : null,
      );

      final data    = response.data as Map<String, dynamic>;
      final records = (data['records'] as List<dynamic>)
          .map((e) => StreetModel.fromApi(e as Map<String, dynamic>))
          .toList();

      return (records: records, lastSyncDate: data['lastSyncDate'] as String);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  @override
  Future<({List<StreetModel> records, String lastSyncDate})> postSyncStreets({
    required List<StreetModel> streets,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.syncStreetsEndpoint,
        data: {'records': streets.map((s) => s.toPostSyncMap()).toList()},
      );

      final data    = response.data as Map<String, dynamic>;
      final records = (data['records'] as List<dynamic>)
          .map((e) => StreetModel.fromApi(e as Map<String, dynamic>))
          .toList();

      return (records: records, lastSyncDate: data['lastSyncDate'] as String);
    } on DioException catch (e) {
      throw NetworkException.fromError(e);
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }
}