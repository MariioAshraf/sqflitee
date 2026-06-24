import 'package:equatable/equatable.dart';
import '../../../home/data/models/tenant_model.dart';

// ════════════════════════════════════════════════════════
//  UserRole enum
// ════════════════════════════════════════════════════════
enum UserRole { priest, headOfService, servant, member }

extension UserRoleX on UserRole {
  String get apiValue => switch (this) {
    UserRole.priest        => 'PRIEST',
    UserRole.headOfService => 'HEAD_OF_SERVICE',
    UserRole.servant       => 'SERVANT',
    UserRole.member        => 'MEMBER',
  };
}

extension StringToUserRole on String {
  UserRole get toUserRole => switch (this) {
    'PRIEST'          => UserRole.priest,
    'HEAD_OF_SERVICE' => UserRole.headOfService,
    'SERVANT'         => UserRole.servant,
    'MEMBER'          => UserRole.member,
    _                 => UserRole.member,
  };
}

// ════════════════════════════════════════════════════════
//  UserEntity
// ════════════════════════════════════════════════════════
class UserEntity extends Equatable {
  final String id;
  final String tenantId;
  final String fullName;
  final String email;
  final String? passwordHash;
  final String phone;
  final String nationalId;
  final DateTime birthDate;
  final String? qrCode;
  final String? photoPath;
  final DateTime? baptismDate;
  final String? confessionPriestId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final UserRole userRole;
  final List<dynamic> roles;
  final TenantModel tenantModel;

  const UserEntity({
    required this.id,
    required this.tenantId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.birthDate,
    required this.createdAt,
    required this.updatedAt,
    required this.userRole,
    required this.tenantModel,
    required this.roles,
    this.passwordHash,
    this.qrCode,
    this.photoPath,
    this.baptismDate,
    this.confessionPriestId,
    this.deletedAt,
  });

  static UserRole roleFromString(String roleStr) => roleStr.toUserRole;

  bool get isPriest => userRole == UserRole.priest;

  @override
  List<Object?> get props => [id, email, userRole];
}