import 'package:expense_repository/expense_repository.dart';

class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;
  String? userId;
  String type;

  Category({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    this.userId,
    required this.type,
  });

  static final empty = Category(
    categoryId: '',
    name: '',
    totalExpenses: 0,
    icon: '',
    color: 0,
    userId: null,
    type: 'expense',
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
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Category(categoryId: $categoryId, name: $name, totalExpenses: $totalExpenses, icon: $icon, color: $color, userId: $userId, type: $type)';
  }
}
