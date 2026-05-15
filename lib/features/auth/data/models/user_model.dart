

import '../../domain/entities/user_entity.dart';

final class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.tenantId,
    required super.email,
    required super.password,
    required super.phone,
    required super.nationalId,
    required super.role,
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id:           map['id']          as String,
      name:         map['name']        as String,
      tenantId:     map['tenantId']    as String,
      email:        map['email']       as String,
      password:     map['password']    as String,
      phone:        map['phone']       as String,
      nationalId:   map['nationalId']  as String,
      role:         map['role']        as String,
      accessToken:  map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
    );
  }

  // لو محتاجه في refreshToken flow
  UserModel copyWithTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return UserModel(
      id:           id,
      name:         name,
      tenantId:     tenantId,
      email:        email,
      password:     password,
      phone:        phone,
      nationalId:   nationalId,
      role:         role,
      accessToken:  accessToken,
      refreshToken: refreshToken,
    );
  }
}