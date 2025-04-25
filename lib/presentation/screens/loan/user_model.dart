class User {
  String name;
  String email;
  String phone;
  String? profileImagePath;

  User({
    required this.name,
    required this.email,
    required this.phone,
    this.profileImagePath,
  });

  // Método para crear una copia del usuario con campos actualizados
  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImagePath,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
