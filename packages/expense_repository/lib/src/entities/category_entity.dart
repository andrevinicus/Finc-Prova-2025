class CategoryEntity {
  final String categoryId;
  final String name;
  final int totalExpenses;
  final String icon;
  final int color;
  final String? userId;
  final String type; // NOVO
  final String createdAt;  // Novo campo para data de criação

  CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    this.userId,
    required this.type, // NOVO
    required this.createdAt,  // Adicionando campo de data de criação
  });

  Map<String, Object?> toDocument() {
    return {
      'categoryId': categoryId,
      'name': name,
      'totalExpenses': totalExpenses,
      'icon': icon,
      'color': color,
      'userId': userId,
      'type': type, // NOVO
      'createdAt': createdAt,  // Adicionando campo de data de criação
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc) {
    return CategoryEntity(
      categoryId: doc['categoryId'],
      name: doc['name'],
      totalExpenses: doc['totalExpenses'],
      icon: doc['icon'],
      color: doc['color'],
      userId: doc['userId'],
      type: doc['type'] ?? 'expense', // NOVO: fallback de segurança
      createdAt: doc['createdAt'] ?? DateTime.now().toIso8601String(),  // Fallback para a data atual, caso não exista
    );
  }
}
