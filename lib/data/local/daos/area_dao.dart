import 'package:sqflite/sqflite.dart';
import '../../../features/home/data/models/area_model.dart';
import '../tables/area_table.dart';

final class AreaDao {
  final Database _db;
  const AreaDao(this._db);

  Future<void> insertOrReplace(AreaModel area) async {
    await _db.insert(
      AreaTable.tableName,
      area.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertOrReplaceAll(List<AreaModel> areas) async {
    final batch = _db.batch();
    for (final area in areas) {
      batch.insert(
        AreaTable.tableName,
        area.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<AreaModel>> getAll({required String tenantId}) async {
    final maps = await _db.query(
      AreaTable.tableName,
      where: '${AreaTable.colTenantId} = ? AND ${AreaTable.colDeletedAt} IS NULL',
      whereArgs: [tenantId],
      orderBy: '${AreaTable.colCreatedAt} DESC',
    );
    return maps.map(AreaModel.fromDb).toList();
  }

  Future<List<AreaModel>> getPendingSync() async {
    final maps = await _db.query(
      AreaTable.tableName,
      where: '${AreaTable.colIsNeedToPostSync} = 1',
    );
    return maps.map(AreaModel.fromDb).toList();
  }

  Future<void> markAsSynced(String id) async {
    await _db.update(
      AreaTable.tableName,
      {AreaTable.colIsNeedToPostSync: 0},
      where: '${AreaTable.colId} = ?',
      whereArgs: [id],
    );
  }
}