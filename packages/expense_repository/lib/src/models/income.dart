import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class Income {
  final String id;
  final String categoryId; // só o ID da categoria
  final double amount;
  final DateTime date;
  final String userId;
  final String type;
  final String description;
  final String? bankId;
  final String? imageId;

  Income({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.userId,
    required this.type,
    required this.description,
    this.bankId,
    this.imageId,
  });

  // Instância vazia
  static Income get empty => Income(
        id: '',
        categoryId: '',
        amount: 0,
        date: DateTime.now(),
        userId: '',
        type: 'despesa',
        description: '',
        bankId: null,
        imageId: null,
      );

  // Copiar com alterações
  Income copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? userId,
    String? type,
    String? description,
    String? bankId,
    String? imageId,
  }) {
    return Income(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      bankId: bankId ?? this.bankId,
      imageId: imageId ?? this.imageId,
    );
  }

  // Criar Income a partir de IncomeEntity
// Criar Income a partir de IncomeEntity
    static Income fromEntity(IncomeEntity entity) {
      return Income(
        id: entity.id,
        categoryId: entity.categoryId,
        amount: entity.amount,
        date: entity.date,
        userId: entity.userId,
        type: entity.type,
        description: entity.description,
        bankId: entity.bankId,
        imageId: entity.imageId,
      );
    }


  // Converter para IncomeEntity (para salvar no Firestore)
  IncomeEntity toEntity() {
    return IncomeEntity(
      id: id,
      categoryId: categoryId,
      amount: amount,
      date: date,
      userId: userId,
      type: type,
      description: description,
      bankId: bankId,
      imageId: imageId,
    );
  }

  // Criar Income a partir de Firestore
  static Income fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Income(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'income',
      description: data['description'] ?? '',
      bankId: data['bankId'],
      imageId: data['imageId'],
    );
  }

  bool get isIncome => type == 'income';
}
