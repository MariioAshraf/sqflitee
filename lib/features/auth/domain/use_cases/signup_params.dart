class SignUpParams {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String nationalId;

   SignUpParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.nationalId,
  });
  Map<String, dynamic> toMap() => {
    'name':       name,
    'email':      email,
    'password':   password,
    'phone':      phone,
    'nationalId': nationalId,
  };
}