class CategoryEntity {
  final String categoryId;
  final String name;
  final int totalExpenses;
  final String icon;
  final int color;
  final String? userId; // NOVO

  CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    this.userId, // NOVO
  });

  Map<String, Object?> toDocument() {
    return {
      'categoryId': categoryId,
      'name': name,
      'totalExpenses': totalExpenses,
      'icon': icon,
      'color': color,
      'userId': userId, // NOVO
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc) {
    return CategoryEntity(
      categoryId: doc['categoryId'],
      name: doc['name'],
      totalExpenses: doc['totalExpenses'],
      icon: doc['icon'],
      color: doc['color'],
      userId: doc['userId'], // NOVO
    );
  }
}
