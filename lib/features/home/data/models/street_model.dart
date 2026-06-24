// lib/features/areas/data/models/street_model.dart

import 'package:uuid/uuid.dart';
import '../../../../data/local/tables/street_table.dart';

final class StreetModel {
  final String  id;
  final String  areaId;
  final String  name;
  final String  createdAt;
  final String  updatedAt;
  final String? deletedAt;
  final bool    isNeedToPostSync;

  const StreetModel({
    required this.id,
    required this.areaId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isNeedToPostSync,
  });

  // ── من الـ DB ────────────────────────────────────────────────
  factory StreetModel.fromDb(Map<String, dynamic> map) => StreetModel(
    id:               map[StreetTable.colId] as String,
    areaId:           map[StreetTable.colAreaId] as String,
    name:             map[StreetTable.colName] as String,
    createdAt:        map[StreetTable.colCreatedAt] as String,
    updatedAt:        map[StreetTable.colUpdatedAt] as String,
    deletedAt:        map[StreetTable.colDeletedAt] as String?,
    isNeedToPostSync: (map[StreetTable.colIsNeedToPostSync] as int) == 1,
  );

  Map<String, dynamic> toDb() => {
    StreetTable.colId:               id,
    StreetTable.colAreaId:           areaId,
    StreetTable.colName:             name,
    StreetTable.colCreatedAt:        createdAt,
    StreetTable.colUpdatedAt:        updatedAt,
    StreetTable.colDeletedAt:        deletedAt,
    StreetTable.colIsNeedToPostSync: isNeedToPostSync ? 1 : 0,
  };

  // ── من الـ API (getSync أو postSync response) ─────────────────
  factory StreetModel.fromApi(Map<String, dynamic> map) => StreetModel(
    id:               map['id']        as String,
    areaId:           map['areaId']    as String,
    name:             map['name']      as String,
    createdAt:        map['createdAt'] as String,
    updatedAt:        map['updatedAt'] as String,
    deletedAt:        map['deletedAt'] as String?,
    isNeedToPostSync: false,
  );

  // ── إنشاء street جديدة محلياً ───────────────────────────────────
  factory StreetModel.createLocal({
    required String areaId,
    required String name,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return StreetModel(
      id:               const Uuid().v4(),
      areaId:           areaId,
      name:             name,
      createdAt:        now,
      updatedAt:        now,
      deletedAt:        null,
      isNeedToPostSync: true,
    );
  }

  // ── للـ postSync body ───────────────────────────────────────────
  Map<String, dynamic> toPostSyncMap() => {
    'id':        id,
    'areaId':    areaId,
    'name':      name,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deletedAt': deletedAt,
  };

  StreetModel copyWith({
    String? name,
    String? updatedAt,
    bool?   isNeedToPostSync,
  }) => StreetModel(
    id:               id,
    areaId:           areaId,
    name:             name ?? this.name,
    createdAt:        createdAt,
    updatedAt:        updatedAt ?? this.updatedAt,
    deletedAt:        deletedAt,
    isNeedToPostSync: isNeedToPostSync ?? this.isNeedToPostSync,
  );
}