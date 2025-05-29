import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class Expense {
  final String id;
  final Category category;
  final double amount;
  final DateTime date;
  final String userId;
  final String type; 
  final String description; 
  final String? bankId;
  final String? imageId; // Opcional para imagens

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.userId,
    required this.type,
    required this.description,
    required this.bankId,
    this.imageId,
  });

  /// Getter para uma instância "vazia"
  static Expense get empty => Expense(
        id: '',
        category: Category.empty,
        date: DateTime.now(),
        amount: 0,
        userId: '',
        type: 'expense',
        description: '',
        bankId: '',
        imageId: null,
      );

  /// Permite criar uma nova instância com modificações
  Expense copyWith({
    String? id,
    Category? category,
    double? amount,
    DateTime? date,
    String? userId,
    String? type,
    String? description,
    String? bankId,
    String? imageId,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      bankId: bankId,
      imageId: imageId ?? this.imageId,
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
      description: map['description'] ?? '',
      bankId: map['bankId'],
      imageId: map['imageId'], // Opcional para imagens
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
      'description': description,
      'bankId': bankId,
      'imageId': imageId,
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
      description: entity.description,
      bankId: entity.bankId,
      imageId: entity.imageId, // Opcional para imagens
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
      description: description,
      bankId: bankId,
      imageId: imageId,
    );
  }
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      category: Category.fromEntity(
        CategoryEntity.fromDocument(data['category']),
      ),
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'despesa',
      description: data['description'] ?? '',
      bankId: data['bankId'],
      imageId: data['imageId'],
    );
  }

  /// Getter útil para lógica: verificar se é uma despesa
  bool get isExpense => type == 'expense';
}
