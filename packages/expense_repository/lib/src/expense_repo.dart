import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory(String userId);  // Método para buscar categorias de um usuário

  Future<void> createExpense(ExpenseEntity expense);

  Future<List<ExpenseEntity>> getExpenses(String userId);
}
