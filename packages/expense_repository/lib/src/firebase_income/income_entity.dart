import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeEntity {
  final String id; // Renomeado de expenseId para id
  final String categoryId; // Armazenar só o ID da categoria
  final DateTime date;
  final double amount; // Usar double
  final String userId;
  final String type; // 'despesa' ou 'receita'
  final String description;
  final String? bankId;
  final String? imageId;

  IncomeEntity({
    required this.id,
    required this.categoryId,
    required this.date,
    required this.amount,
    required this.userId,
    required this.type,
    required this.description,
    this.bankId,
    this.imageId,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'userId': userId,
      'type': type,
      'description': description,
      'bankId': bankId,
      'imageId': imageId,
    };
  }

  static IncomeEntity fromDocument(Map<String, dynamic> doc) {
    return IncomeEntity(
      id: doc['id'] as String,
      categoryId: doc['categoryId'] as String,
      date: (doc['date'] as Timestamp).toDate(),
      amount: (doc['amount'] as num).toDouble(),
      userId: doc['userId'] as String,
      type: doc['type'] as String? ?? 'income',
      description: doc['description'] as String? ?? '',
      bankId: doc['bankId'] as String?,
      imageId: doc['imageId'] as String?,
    );
  }
}
