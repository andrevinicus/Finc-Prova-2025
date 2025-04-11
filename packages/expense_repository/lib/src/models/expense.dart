import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class Expense {
  final String id;
  final Category category;
  final double amount;
  final DateTime date;
  final String userId;
  final String type; // 'despesa' ou 'receita'

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.userId,
    required this.type,
  });

  /// Getter para uma instância "vazia"
  static Expense get empty => Expense(
        id: '',
        category: Category.empty,
        date: DateTime.now(),
        amount: 0,
        userId: '',
        type: 'despesa',
      );

  /// Permite criar uma nova instância com modificações
  Expense copyWith({
    String? id,
    Category? category,
    double? amount,
    DateTime? date,
    String? userId,
    String? type,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      type: type ?? this.type,
    );
  }

  /// Cria um `Expense` a partir de um `Map`
  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      category: Category.fromEntity(
        CategoryEntity.fromDocument(map['category']),
      ),
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'despesa',
    );
  }

  /// Converte para `Map<String, dynamic>` para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category.toEntity().toDocument(),
      'amount': amount,
      'date': date,
      'userId': userId,
      'type': type,
    };
  }

  /// Conversão de `ExpenseEntity` para `Expense`
  static Expense fromEntity(ExpenseEntity entity) {
    return Expense(
      id: entity.expenseId,
      category: entity.category,
      amount: entity.amount.toDouble(),
      date: entity.date,
      userId: entity.userId,
      type: entity.type,
    );
  }

  /// Conversão de `Expense` para `ExpenseEntity`
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: id,
      category: category,
      date: date,
      amount: amount.toInt(),
      userId: userId,
      type: type,
    );
  }

  /// Getter útil para lógica: verificar se é uma despesa
  bool get isExpense => type == 'despesa';
}
