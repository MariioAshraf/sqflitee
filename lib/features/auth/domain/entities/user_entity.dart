class UserEntity {
  final String id;
  final String name;
  final String tenantId;
  final String email;
  final String password;
  final String phone;
  final String nationalId;
  final String role;
  final String accessToken;
  final String refreshToken;

  const UserEntity({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.email,
    required this.password,
    required this.phone,
    required this.nationalId,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });
}