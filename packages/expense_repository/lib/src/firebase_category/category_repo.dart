import 'package:expense_repository/expense_repository.dart';

abstract class CategoryRepository {
  /// Cria uma nova categoria
  Future<void> createCategory(Category category);

  /// Retorna todas as categorias de um usuário
  Future<List<Category>> getCategories(String userId);
}
