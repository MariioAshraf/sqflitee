import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../models/street_model.dart';

abstract interface class StreetsRepo {
  Future<Either<Failure, List<StreetModel>>> getLocalStreets({
    required String areaId,
  });

  Future<Either<Failure, StreetModel>> createStreetLocally({
    required String areaId,
    required String name,
  });

  Future<Either<Failure, void>> syncPendingStreets();

  Future<Either<Failure, void>> pullStreetsFromServer();
}