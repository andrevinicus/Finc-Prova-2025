import 'package:expense_repository/src/user/user_entity.dart';

class UserModel extends UserEntity {
  final String? fcmToken; // ✅ campo adicional, não presente em UserEntity

  const UserModel({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    required String telefone,
    this.fcmToken,
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
      fcmToken: map['fcmToken'], // ✅ carrega token se existir
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'telefone': telefone,
      if (fcmToken != null) 'fcmToken': fcmToken, // ✅ evita salvar null
    };
  }

  factory UserModel.fromEntity(UserEntity entity, {String? fcmToken}) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      telefone: entity.telefone,
      fcmToken: fcmToken,
    );
  }

  UserEntity toEntity() => UserEntity(
        uid: uid,
        name: name,
        email: email,
        photoUrl: photoUrl,
        telefone: telefone,
      );

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? telefone,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      telefone: telefone ?? this.telefone,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, telefone: $telefone, photoUrl: $photoUrl, fcmToken: $fcmToken)';
  }
}
