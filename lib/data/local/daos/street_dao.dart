import 'package:sqflite/sqflite.dart';
import '../../../features/home/data/models/street_model.dart';
import '../tables/street_table.dart';


final class StreetDao {
  final Database _db;
  const StreetDao(this._db);

  Future<void> insertOrReplace(StreetModel street) async {
    await _db.insert(
      StreetTable.tableName,
      street.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertOrReplaceAll(List<StreetModel> streets) async {
    final batch = _db.batch();
    for (final street in streets) {
      batch.insert(
        StreetTable.tableName,
        street.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// كل الـ streets بتاعت area واحدة
  Future<List<StreetModel>> getByAreaId(String areaId) async {
    final maps = await _db.query(
      StreetTable.tableName,
      where: '${StreetTable.colAreaId} = ? AND ${StreetTable.colDeletedAt} IS NULL',
      whereArgs: [areaId],
      orderBy: '${StreetTable.colCreatedAt} DESC',
    );
    return maps.map(StreetModel.fromDb).toList();
  }

  /// كل الـ streets بتاعت كل الـ areas دفعة واحدة — مهم للأداء
  /// عشان منعملش query لكل area لوحدها (N+1 problem)
  Future<Map<String, List<StreetModel>>> getGroupedByAreaIds(
      List<String> areaIds,
      ) async {
    if (areaIds.isEmpty) return {};

    final placeholders = List.filled(areaIds.length, '?').join(',');
    final maps = await _db.query(
      StreetTable.tableName,
      where: '${StreetTable.colAreaId} IN ($placeholders) '
          'AND ${StreetTable.colDeletedAt} IS NULL',
      whereArgs: areaIds,
      orderBy: '${StreetTable.colCreatedAt} DESC',
    );

    final streets = maps.map(StreetModel.fromDb).toList();
    final grouped = <String, List<StreetModel>>{};
    for (final street in streets) {
      grouped.putIfAbsent(street.areaId, () => []).add(street);
    }
    return grouped;
  }

  Future<List<StreetModel>> getPendingSync() async {
    final maps = await _db.query(
      StreetTable.tableName,
      where: '${StreetTable.colIsNeedToPostSync} = 1',
    );
    return maps.map(StreetModel.fromDb).toList();
  }

  Future<void> markAsSynced(String id) async {
    await _db.update(
      StreetTable.tableName,
      {StreetTable.colIsNeedToPostSync: 0},
      where: '${StreetTable.colId} = ?',
      whereArgs: [id],
    );
  }
}