import 'package:sqflitee/features/home/data/models/street_model.dart';
import 'area_model.dart';

final class AreaWithStreets {
  final AreaModel        area;
  final List<StreetModel> streets;

  const AreaWithStreets({required this.area, required this.streets});
}