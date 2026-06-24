// lib/features/areas/data/models/area_model.dart

import 'package:uuid/uuid.dart';

import '../../../../data/local/tables/area_table.dart';

final class AreaModel {
  final String  id;
  final String  tenantId;
  final String  name;
  final String? responsiblePriestId;
  final String  createdAt;
  final String  updatedAt;
  final String? deletedAt;
  final bool    isNeedToPostSync;

  const AreaModel({
    required this.id,
    required this.tenantId,
    required this.name,
    this.responsiblePriestId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.isNeedToPostSync,
  });

  // ── من الـ DB (sqflite بيخزن bool كـ 0/1) ───────────────────
  factory AreaModel.fromDb(Map<String, dynamic> map) => AreaModel(
    id:                   map[AreaTable.colId] as String,
    tenantId:             map[AreaTable.colTenantId] as String,
    name:                 map[AreaTable.colName] as String,
    responsiblePriestId:  map[AreaTable.colResponsiblePriestId] as String?,
    createdAt:            map[AreaTable.colCreatedAt] as String,
    updatedAt:            map[AreaTable.colUpdatedAt] as String,
    deletedAt:            map[AreaTable.colDeletedAt] as String?,
    isNeedToPostSync:     (map[AreaTable.colIsNeedToPostSync] as int) == 1,
  );

  Map<String, dynamic> toDb() => {
    AreaTable.colId:                  id,
    AreaTable.colTenantId:            tenantId,
    AreaTable.colName:                name,
    AreaTable.colResponsiblePriestId: responsiblePriestId,
    AreaTable.colCreatedAt:           createdAt,
    AreaTable.colUpdatedAt:           updatedAt,
    AreaTable.colDeletedAt:           deletedAt,
    AreaTable.colIsNeedToPostSync:    isNeedToPostSync ? 1 : 0,
  };

  // ── من الـ API (getSync أو postSync response) ──────────────
  // أي record جاي من السيرفر isNeedToPostSync = false دايماً
  factory AreaModel.fromApi(Map<String, dynamic> map) => AreaModel(
    id:                  map['id']        as String,
    tenantId:            map['tenantId']  as String,
    name:                map['name']      as String,
    responsiblePriestId: map['responsiblePriestId'] as String?,
    createdAt:           map['createdAt'] as String,
    updatedAt:           map['updatedAt'] as String,
    deletedAt:           map['deletedAt'] as String?,
    isNeedToPostSync:    false,
  );

  // ── إنشاء area جديدة محلياً (قبل أي sync) ───────────────────
  factory AreaModel.createLocal({
    required String tenantId,
    required String name,
    String? responsiblePriestId,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return AreaModel(
      id:                  const Uuid().v4(),
      tenantId:            tenantId,
      name:                name,
      responsiblePriestId: responsiblePriestId,
      createdAt:           now,
      updatedAt:           now,
      deletedAt:           null,
      isNeedToPostSync:    true, // ← لسه متبعتش للسيرفر
    );
  }

  // ── للـ postSync body — بدون isNeedToPostSync ────────────────
  Map<String, dynamic> toPostSyncMap() => {
    'id':        id,
    'tenantId':  tenantId,
    'name':      name,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deletedAt': deletedAt,
  };

  AreaModel copyWith({
    String?  name,
    String?  updatedAt,
    bool?    isNeedToPostSync,
  }) => AreaModel(
    id:                  id,
    tenantId:             tenantId,
    name:                name ?? this.name,
    responsiblePriestId: responsiblePriestId,
    createdAt:           createdAt,
    updatedAt:           updatedAt ?? this.updatedAt,
    deletedAt:           deletedAt,
    isNeedToPostSync:    isNeedToPostSync ?? this.isNeedToPostSync,
  );
}