import 'package:expense_repository/src/entities/bank_entity.dart'; // ajuste o import conforme seu projeto

class BankModel extends BankEntity {
  const BankModel({
    required String code,
    required String name,
    required String logo,
    required String userId,
  }) : super(code: code, name: name, logo: logo, userId: userId);

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      userId: json['userId'] ?? '', // Adicione o campo userId se necessário
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'logo': logo,
      'userId': userId,
    };
  }
}

