// ════════════════════════════════════════════════════════
//  UserModel — بدون أي password hashing
// ════════════════════════════════════════════════════════
import '../../../../data/local/tables/user_table.dart';
import '../../../home/data/models/tenant_model.dart';
import '../../domain/entities/user_entity.dart';

final class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.tenantId,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.nationalId,
    required super.birthDate,
    required super.createdAt,
    required super.updatedAt,
    required super.userRole,
    required super.tenantModel,
    required super.roles,
    super.passwordHash,
    super.qrCode,
    super.photoPath,
    super.baptismDate,
    super.confessionPriestId,
    super.deletedAt,
  });

  // ── من الـ API ────────────────────────────────────────
  factory UserModel.fromApi(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      nationalId: json['nationalId'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      qrCode: json['qrCode'] as String?,
      photoPath: json['photoPath'] as String?,
      baptismDate: json['baptismDate'] != null
          ? DateTime.parse(json['baptismDate'] as String)
          : null,
      confessionPriestId: json['confessionPriestId'] as String?,
      userRole: (json['userRole'] as String? ?? 'MEMBER').toUserRole,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      roles: const [],
      tenantModel: TenantModel.fromMap(
        json['tenant'] as Map<String, dynamic>,
      ),
      // ✅ بنخزن الـ bcrypt hash الجاي من الـ server عشان نستخدمه offline
      passwordHash: json['passwordHash'] as String?,
    );
  }

  // ── من الـ local DB ───────────────────────────────────
  factory UserModel.fromDb(Map<String, dynamic> map) {
    return UserModel(
      id: map[UserTable.colId] as String,
      tenantId: map[UserTable.colTenantId] as String,
      fullName: map[UserTable.colFullName] as String,
      email: map[UserTable.colEmail] as String,
      phone: map[UserTable.colPhone] as String,
      nationalId: map[UserTable.colNationalId] as String,
      birthDate: DateTime.parse(map[UserTable.colBirthDate] as String),
      qrCode: map[UserTable.colQrCode] as String?,
      photoPath: map[UserTable.colPhotoPath] as String?,
      baptismDate: map[UserTable.colBaptismDate] != null
          ? DateTime.parse(map[UserTable.colBaptismDate] as String)
          : null,
      confessionPriestId: map[UserTable.colConfessionPriestId] as String?,
      userRole: (map[UserTable.colUserRole] as String? ?? 'MEMBER').toUserRole,
      createdAt: DateTime.parse(map[UserTable.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[UserTable.colUpdatedAt] as String),
      deletedAt: map[UserTable.colDeletedAt] != null
          ? DateTime.parse(map[UserTable.colDeletedAt] as String)
          : null,
      passwordHash: map[UserTable.colPasswordHash] as String?,
      roles: const [],
      tenantModel: TenantModel.fromDb(map),
    );
  }

  // ── للـ local DB ──────────────────────────────────────
  Map<String, dynamic> toDb() => {
    UserTable.colId: id,
    UserTable.colTenantId: tenantId,
    UserTable.colFullName: fullName,
    UserTable.colEmail: email,
    UserTable.colPhone: phone,
    UserTable.colNationalId: nationalId,
    UserTable.colBirthDate: birthDate.toIso8601String(),
    UserTable.colQrCode: qrCode,
    UserTable.colPhotoPath: photoPath,
    UserTable.colBaptismDate: baptismDate?.toIso8601String(),
    UserTable.colConfessionPriestId: confessionPriestId,
    UserTable.colUserRole: userRole.apiValue,
    // ✅ بنخزن الـ bcrypt hash من الـ server
    UserTable.colPasswordHash: passwordHash,
    UserTable.colCreatedAt: createdAt.toIso8601String(),
    UserTable.colUpdatedAt: updatedAt.toIso8601String(),
    UserTable.colDeletedAt: deletedAt?.toIso8601String(),
  };
}