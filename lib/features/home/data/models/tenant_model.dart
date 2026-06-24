import 'package:sqflitee/features/home/data/models/tenant_entity.dart';
import '../../../../data/local/tables/tenant_table.dart';

final class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.name,
    required super.code,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  // ── من الـ API ────────────────────────────────────────
  factory TenantModel.fromMap(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  // ── من الـ local DB ───────────────────────────────────
  // بيقرأ من الـ aliases اللي بيعملها UserDao في الـ JOIN
  // مثلاً: map['t_id'], map['t_name'], ...
  factory TenantModel.fromDb(Map<String, dynamic> map) {
    return TenantModel(
      id: map[TenantTable.colIdAlias] as String,
      name: map[TenantTable.colNameAlias] as String,
      code: map[TenantTable.colCodeAlias] as String,
      createdAt: DateTime.parse(map[TenantTable.colCreatedAtAlias] as String),
      updatedAt: DateTime.parse(map[TenantTable.colUpdatedAtAlias] as String),
      deletedAt: map[TenantTable.colDeletedAtAlias] != null
          ? DateTime.parse(map[TenantTable.colDeletedAtAlias] as String)
          : null,
    );
  }

  // ── للـ local DB ──────────────────────────────────────
  Map<String, dynamic> toDb() => {
    TenantTable.colId: id,
    TenantTable.colName: name,
    TenantTable.colCode: code,
    TenantTable.colCreatedAt: createdAt.toIso8601String(),
    TenantTable.colUpdatedAt: updatedAt.toIso8601String(),
    TenantTable.colDeletedAt: deletedAt?.toIso8601String(),
  };
}
