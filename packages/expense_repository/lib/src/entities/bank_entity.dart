import 'package:equatable/equatable.dart';

class BankAccountEntity extends Equatable {
  final String id;
  final String descricao;
  final String bankName;
  final String? bankCode;
  final String? logo;       // Novo campo para logo
  final double initialBalance;
  final int colorHex;
  final String userId;

  const BankAccountEntity({
    required this.id,
    required this.descricao,
    required this.bankName,
    this.bankCode,
    this.logo,
    required this.initialBalance,
    required this.colorHex,
    required this.userId,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'descricao': descricao,
      'bankName': bankName,
      'bankCode': bankCode,
      'logo': logo,
      'initialBalance': initialBalance,
      'colorHex': colorHex,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        descricao,
        bankName,
        bankCode ?? '',
        logo ?? '',
        initialBalance,
        colorHex,
        userId,
      ];
}
