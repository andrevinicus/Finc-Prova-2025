import 'package:expense_repository/expense_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseEntity {
  final String expenseId;
  final Category category;
  final DateTime date;
  final int amount;
  final String userId;
  final String type; // 'despesa' ou 'receita'
  final String description;
  final String? bankId;
  final String? imageId; // alterado de idImg para imageId

  ExpenseEntity({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
    required this.userId,
    required this.type,
    required this.description,
    required this.bankId,
    this.imageId,
  });

  Map<String, Object?> toDocument() {
    return {
      'expenseId': expenseId,
      'category': category.toEntity().toDocument(),
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
      category: Category.fromEntity(
        CategoryEntity.fromDocument(doc['category'] as Map<String, dynamic>),
      ),
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
