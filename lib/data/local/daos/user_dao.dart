import 'package:sqflite/sqflite.dart';
import '../../../../data/local/tables/tenant_table.dart';
import '../../../../data/local/tables/user_table.dart';
import '../../../features/auth/data/models/user_model.dart';


class UserDao {
  final Database db;

  UserDao(this.db);

  // ── cacheUser ─────────────────────────────────────────
  // بنخزن الـ tenant الأول عشان الـ FOREIGN KEY في users
  // لو خزّنا الـ user الأول هيطلع error: tenant مش موجود
  Future<void> cacheUser(UserModel user) async {
    await db.transaction((txn) async {
      // 1. tenant
      await txn.insert(
        TenantTable.tableName,
        user.tenantModel.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. user
      await txn.insert(
        UserTable.tableName,
        user.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // ── getUserByEmail ────────────────────────────────────
  // rawQuery عشان محتاجين JOIN — db.query بتشتغل على جدول واحد بس
  // بنعمل alias للـ tenant columns عشان مفيش conflict مع users columns
  Future<UserModel?> getUserByEmail(String email) async {
    final result = await db.rawQuery(
      '''
      SELECT
        u.*,
        t.${TenantTable.colId}         AS ${TenantTable.colIdAlias},
        t.${TenantTable.colName}        AS ${TenantTable.colNameAlias},
        t.${TenantTable.colCode}        AS ${TenantTable.colCodeAlias},
        t.${TenantTable.colCreatedAt}   AS ${TenantTable.colCreatedAtAlias},
        t.${TenantTable.colUpdatedAt}   AS ${TenantTable.colUpdatedAtAlias},
        t.${TenantTable.colDeletedAt}   AS ${TenantTable.colDeletedAtAlias}
      FROM ${UserTable.tableName} u
      INNER JOIN ${TenantTable.tableName} t
        ON u.${UserTable.colTenantId} = t.${TenantTable.colId}
      WHERE u.${UserTable.colEmail} = ?
      LIMIT 1
      ''',
      [email],
    );

    if (result.isEmpty) return null;

    return UserModel.fromDb(result.first);
  }
}

