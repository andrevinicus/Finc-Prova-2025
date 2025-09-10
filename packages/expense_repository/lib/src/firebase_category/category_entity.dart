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
    categoryId: doc['categoryId'] as String,
    name: doc['name'] as String,
    totalExpenses: (doc['totalExpenses'] as num).toInt(), // converte double/int para int
    icon: doc['icon'] as String,
    color: (doc['color'] as num).toInt(), // converte double/int para int
    userId: doc['userId'] as String?,
    type: doc['type'] as String? ?? 'income',
    createdAt: doc['createdAt'] as String? ?? DateTime.now().toIso8601String(),
  );
}
}
