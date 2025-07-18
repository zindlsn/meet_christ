class User {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  set(String id) => User(
    name: name,
    email: email,
    profilePictureUrl: profilePictureUrl,
    id: id,
  );

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, profilePictureUrl: $profilePictureUrl}';
  }
}
