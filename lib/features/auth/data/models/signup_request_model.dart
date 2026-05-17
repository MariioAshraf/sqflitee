



import '../../domain/use_cases/signup_params.dart';

final class SignUpRequestModel {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String nationalId;

  const SignUpRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.nationalId,
  });

  factory SignUpRequestModel.fromParams(SignUpParams params) {
    return SignUpRequestModel(
      name:       params.name,
      email:      params.email,
      password:   params.password,
      phone:      params.phone,
      nationalId: params.nationalId,
    );
  }

  Map<String, dynamic> toMap() => {
    'name':       name,
    'email':      email,
    'password':   password,
    'phone':      phone,
    'nationalId': nationalId,
  };
}