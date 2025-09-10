import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class Expense {
  final String id;
  final String categoryId;   // só o ID
  final double amount;
  final DateTime date;
  final String userId;
  final String type; 
  final String description;
  final String? bankId;
  final String? imageId;

  Expense({
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

  /// Converte de ExpenseEntity
  factory Expense.fromEntity(ExpenseEntity entity, {String? categoryName}) {
    return Expense(
      id: entity.expenseId,
      categoryId: entity.categoryId,
      amount: entity.amount.toDouble(),
      date: entity.date,
      userId: entity.userId,
      type: entity.type,
      description: entity.description,
      bankId: entity.bankId,
      imageId: entity.imageId,
    );
  }

  /// Converte para ExpenseEntity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: id,
      categoryId: categoryId,
      date: date,
      amount: amount.toInt(),
      userId: userId,
      type: type,
      description: description,
      bankId: bankId,
      imageId: imageId,
    );
  }
  static Expense fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Expense(
    id: doc.id,
    categoryId: data['categoryId'] ?? '',
    amount: (data['amount'] ?? 0).toDouble(),
    date: (data['date'] as Timestamp).toDate(),
    userId: data['userId'] ?? '',
    type: data['type'] ?? 'expense',
    description: data['description'] ?? '',
    bankId: data['bankId'],
    imageId: data['imageId'],
  );
}

}
