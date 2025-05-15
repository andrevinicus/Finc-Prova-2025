import 'package:expense_repository/expense_repository.dart';

class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;
  String? userId;
  String type;
  DateTime createdAt; // Novo campo para data de criação

  Category({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    this.userId,
    required this.type,
    required this.createdAt, // Novo campo no construtor
  });

  static final empty = Category(
    categoryId: '',
    name: '',
    totalExpenses: 0,
    icon: '',
    color: 0,
    userId: null,
    type: 'expense',
    createdAt: DateTime.now(), // Definindo data de criação como a data atual
  );

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      totalExpenses: totalExpenses,
      icon: icon,
      color: color,
      userId: userId,
      type: type,
      createdAt: createdAt.toIso8601String(), // Convertendo a data para string
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      categoryId: entity.categoryId,
      name: entity.name,
      totalExpenses: entity.totalExpenses,
      icon: entity.icon,
      color: entity.color,
      userId: entity.userId,
      type: entity.type,
      createdAt: DateTime.parse(entity.createdAt), // Convertendo de volta para DateTime
    );
  }

  Category copyWith({
    String? categoryId,
    String? name,
    int? totalExpenses,
    String? icon,
    int? color,
    String? userId,
    String? type,
    DateTime? createdAt, // Permitir modificação da data de criação
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt, // Se não passar, mantém a original
    );
  }

  @override
  String toString() {
    return 'Category(categoryId: $categoryId, name: $name, totalExpenses: $totalExpenses, icon: $icon, color: $color, userId: $userId, type: $type, createdAt: $createdAt)';
  }
}
