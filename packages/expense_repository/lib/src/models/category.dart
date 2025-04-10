import 'package:expense_repository/expense_repository.dart';

class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;
  String? userId; // NOVO

  Category({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    this.userId, // NOVO
  });

  static final empty = Category(
    categoryId: '', 
    name: '', 
    totalExpenses: 0, 
    icon: '', 
    color: 0,
    userId: null, // NOVO
  );

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      totalExpenses: totalExpenses,
      icon: icon,
      color: color,
      userId: userId,
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
    );
  }
}
