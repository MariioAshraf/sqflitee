import 'package:equatable/equatable.dart';

enum UserRole { user, priest, unknown }

extension UserRoleX on UserRole {
  String toJson() => switch (this) {
    UserRole.priest  => 'priest',
    UserRole.user    => 'user',
    UserRole.unknown => 'unknown',
  };

  static UserRole fromJson(String? role) => switch (role) {
    'priest' => UserRole.priest,
    'user'   => UserRole.user,
    _        => UserRole.unknown,
  };
}

class UserEntity extends Equatable {
  final String  id;
  final String  name;
  final String  tenantId;
  final String  email;
  final String  phone;
  final String  nationalId;
  final UserRole role;
  final String  accessToken;
  final String  refreshToken;

  // password مكانهوش في الـ Entity خالص
  // الـ Entity بيمثل الـ domain object — مش بيشيل credentials

  const UserEntity({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  bool get isPriest => role == UserRole.priest;

  UserEntity copyWith({
    String?   id,
    String?   name,
    String?   tenantId,
    String?   email,
    String?   phone,
    String?   nationalId,
    UserRole? role,
    String?   accessToken,
    String?   refreshToken,
  }) {
    return UserEntity(
      id:           id           ?? this.id,
      name:         name         ?? this.name,
      tenantId:     tenantId     ?? this.tenantId,
      email:        email        ?? this.email,
      phone:        phone        ?? this.phone,
      nationalId:   nationalId   ?? this.nationalId,
      role:         role         ?? this.role,
      accessToken:  accessToken  ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  List<Object?> get props => [id, email, role];
}