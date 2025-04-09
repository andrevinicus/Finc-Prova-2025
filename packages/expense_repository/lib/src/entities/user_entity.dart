class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String telefone;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.telefone,
  });
}
