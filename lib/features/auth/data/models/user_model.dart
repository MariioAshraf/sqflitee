import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../data/local/tables/user_table.dart';
import '../../domain/entities/user_entity.dart';

final class UserModel extends UserEntity {
  // الـ passwordHash موجود في الـ Model بس — مش في الـ Entity
  // بيتخزن locally فقط، مش بييجي من الـ API
  final String? passwordHash;

  const UserModel({
    required super.id,
    required super.name,
    required super.tenantId,
    required super.email,
    required super.phone,
    required super.nationalId,
    required super.role,
    required super.accessToken,
    required super.refreshToken,
    this.passwordHash,
  });

  // ── من الـ API (مفيش password هنا) ──────────────────
  factory UserModel.fromApi(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      tenantId: map['tenantId'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      nationalId: map['nationalId'] as String,
      role: UserRoleX.fromJson(map['role'] as String?),
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
      passwordHash: null, // الـ API مبيرجعش password
    );
  }

  // ── من الـ local DB (فيه passwordHash) ──────────────
  factory UserModel.fromDb(Map<String, dynamic> map) {
    return UserModel(
      id:           map[UserTable.colId]           as String,
      name:         map[UserTable.colName]         as String,
      tenantId:     map[UserTable.colTenantId]     as String,
      email:        map[UserTable.colEmail]        as String,
      phone:        map[UserTable.colPhone]        as String,
      nationalId:   map[UserTable.colNationalId]   as String,
      role:         UserRoleX.fromJson(map[UserTable.colRole] as String?),
      accessToken:  map[UserTable.colAccessToken]  as String,
      refreshToken: map[UserTable.colRefreshToken] as String,
      passwordHash: map[UserTable.colPasswordHash] as String?, // nullable
    );
  }

  // ── للـ local DB ─────────────────────────────────────
  Map<String, dynamic> toDb() {
    return {
      UserTable.colId:           id,
      UserTable.colName:         name,
      UserTable.colTenantId:     tenantId,
      UserTable.colEmail:        email,
      UserTable.colPhone:        phone,
      UserTable.colNationalId:   nationalId,
      UserTable.colRole:         role.toJson(),
      UserTable.colAccessToken:  accessToken,
      UserTable.colRefreshToken: refreshToken,
      UserTable.colPasswordHash: passwordHash, // ← hash
    };
  }

  // ── بيبني UserModel من Entity + يضيف الـ hash ────────
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      tenantId: entity.tenantId,
      email: entity.email,
      phone: entity.phone,
      nationalId: entity.nationalId,
      role: entity.role,
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
    );
  }

  // ── Hash الـ password قبل التخزين ───────────────────
  UserModel withHashedPassword(String plainPassword) {
    return UserModel(
      id: id,
      name: name,
      tenantId: tenantId,
      email: email,
      phone: phone,
      nationalId: nationalId,
      role: role,
      accessToken: accessToken,
      refreshToken: refreshToken,
      passwordHash: _hashPassword(plainPassword),
    );
  }

  bool verifyPassword(String plainPassword) {
    if (passwordHash == null) return false;
    return _hashPassword(plainPassword) == passwordHash;
  }

  // ── Tokens refresh ───────────────────────────────────
  UserModel copyWithTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return UserModel(
      id: id,
      name: name,
      tenantId: tenantId,
      email: email,
      phone: phone,
      nationalId: nationalId,
      role: role,
      accessToken: accessToken,
      refreshToken: refreshToken,
      passwordHash: passwordHash,
    );
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
