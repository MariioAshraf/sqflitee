class OldUserModel {
  final int? id;
  final String name;
  final String email;
  final String? nationalId;
  final String? age;

  OldUserModel({
    this.id,
    required this.name,
    required this.email,
    this.nationalId,
    this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'nationalId': nationalId,
      'age': age,
    };
  }
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, nationalId: $nationalId, age: $age)';
  }
  factory OldUserModel.fromMap(Map<String, dynamic> map) {
    return OldUserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      nationalId: map['nationalId'],
      age: map['age'],
    );
  }
}
