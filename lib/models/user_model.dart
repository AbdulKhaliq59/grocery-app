class User {
  final int? id;
  final String email;
  final String password;
  final String? name;
  final String? profileImage;

  User({
    this.id,
    required this.email,
    required this.password,
    this.name,
    this.profileImage,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      profileImage: map['profile_image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'profile_image': profileImage,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
