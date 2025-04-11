import 'package:expense_repository/expense_repository.dart';


abstract class ExpenseRepository {
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory(String userId); // <- atualizado aqui

  Future<void> createExpense(ExpenseEntity expense);

  Future<List<ExpenseEntity>> getExpenses(String userId);
}