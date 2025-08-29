
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseEntity {
  final String expenseId;
  final String categoryId; // apenas o ID da categoria
  final DateTime date;
  final int amount;
  final String userId;
  final String type; // 'despesa' ou 'receita'
  final String description;
  final String? bankId;
  final String? imageId;
  
  ExpenseEntity({
    required this.expenseId,
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
      'expenseId': expenseId,
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

  static ExpenseEntity fromDocument(Map<String, dynamic> doc) {
    return ExpenseEntity(
      expenseId: doc['expenseId'] as String,
      categoryId: doc['categoryId'] as String,
      date: (doc['date'] as Timestamp).toDate(),
      amount: (doc['amount'] as num).toInt(),
      userId: doc['userId'] as String,
      type: doc['type'] ?? 'expense',
      description: doc['description'] ?? '',
      bankId: doc['bankId'] as String?,
      imageId: doc['imageId'] as String?,
    );
  }
}
