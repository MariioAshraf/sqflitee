class User {
  final int? id;
  final String name;
  final String email;
  final String? nationalId;
  final String? age;

  User({
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
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      nationalId: map['nationalId'],
      age: map['age'],
    );
  }
}
