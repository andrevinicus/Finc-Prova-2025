import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/entities/entities.dart';


class BankAccountModel extends BankAccountEntity {
  final Timestamp? createdAt;

  const BankAccountModel({
    required String id,
    required String descricao,
    required String bankName,
    String? bankCode,
    String? logo,
    required double initialBalance,
    required int colorHex,
    required String userId,
    this.createdAt,
  }) : super(
          id: id,
          descricao: descricao,
          bankName: bankName,
          bankCode: bankCode,
          logo: logo,
          initialBalance: initialBalance,
          colorHex: colorHex,
          userId: userId,
        );

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      descricao: json['descricao'] as String,
      bankName: json['bankName'] as String,
      bankCode: json['bankCode'] as String?,
      logo: json['logo'] as String?,
      initialBalance: (json['initialBalance'] as num).toDouble(),
      colorHex: json['colorHex'] as int,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'bankName': bankName,
      'bankCode': bankCode,
      'logo': logo,
      'initialBalance': initialBalance,
      'colorHex': colorHex,
      'userId': userId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
  BankAccountEntity toEntity() {
  return BankAccountEntity(
    id: id,
    descricao: descricao,
    bankName: bankName,
    bankCode: bankCode,
    logo: logo,
    initialBalance: initialBalance,
    colorHex: colorHex,
    userId: userId,
  );
}

  // Novo método para converter Entity -> Model
  factory BankAccountModel.fromEntity(BankAccountEntity entity) {
    return BankAccountModel(
      id: entity.id,
      descricao: entity.descricao,
      bankName: entity.bankName,
      bankCode: entity.bankCode,
      logo: entity.logo,
      initialBalance: entity.initialBalance,
      colorHex: entity.colorHex,
      userId: entity.userId,
      createdAt: null, // ou Timestamp.now(), se quiser colocar data atual
    );
  }
}
