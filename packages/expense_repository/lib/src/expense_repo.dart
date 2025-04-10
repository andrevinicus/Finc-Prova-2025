import 'package:expense_repository/expense_repository.dart';


abstract class ExpenseRepository {
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory(String userId); // <- atualizado aqui

  Future<void> createExpense(Expense expense);

  Future<List<Expense>> getExpenses(String userId);
}