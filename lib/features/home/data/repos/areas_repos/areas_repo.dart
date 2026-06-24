import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../models/area_model.dart';

abstract interface class AreasRepo {
  /// بيرجع الـ areas المحلية فوراً — مفيش انتظار للنت
  Future<Either<Failure, List<AreaModel>>> getLocalAreas();

  /// بتعمل create محلي فقط — مرقم isNeedToPostSync = true
  Future<Either<Failure, AreaModel>> createAreaLocally({
    required String name,
  });

  /// بترفع كل الـ areas المعلقة للسيرفر
  Future<Either<Failure, void>> syncPendingAreas();

  /// بتجيب التحديثات من السيرفر وتدمجها محلياً
  Future<Either<Failure, void>> pullAreasFromServer();
}
