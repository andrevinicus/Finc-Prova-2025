import 'package:expense_repository/expense_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseEntity {
  final String expenseId;
  final Category category;
  final DateTime date;
  final int amount;
  final String userId;
  final String type; // 'despesa' ou 'receita'

  ExpenseEntity({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
    required this.userId,
    required this.type,
  });

  /// Converte a entidade para um documento (mapa) do Firestore
  Map<String, Object?> toDocument() {
    return {
      'expenseId': expenseId,
      'category': category.toEntity().toDocument(),
      'date': Timestamp.fromDate(date), // importante: Firestore precisa de Timestamp
      'amount': amount,
      'userId': userId,
      'type': type,
    };
  }

  /// Constrói a entidade a partir de um documento do Firestore
  static ExpenseEntity fromDocument(Map<String, dynamic> doc) {
    return ExpenseEntity(
      expenseId: doc['expenseId'] as String,
      category: Category.fromEntity(
        CategoryEntity.fromDocument(doc['category'] as Map<String, dynamic>),
      ),
      date: (doc['date'] as Timestamp).toDate(),
      amount: (doc['amount'] as num).toInt(),
      userId: doc['userId'] as String,
      type: doc['type'] ?? 'despesa',
    );
  }
}
