import 'package:expense_repository/src/user/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    required String telefone,
  }) : super(
          uid: uid,
          name: name,
          email: email,
          photoUrl: photoUrl,
          telefone: telefone,
        );

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      telefone: map['telefone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'telefone': telefone,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      telefone: entity.telefone,
    );
  }

  UserEntity toEntity() => this;

  /// ✅ Método útil para atualizações parciais no Bloc
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? telefone,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      telefone: telefone ?? this.telefone,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, telefone: $telefone, photoUrl: $photoUrl)';
  }
}
