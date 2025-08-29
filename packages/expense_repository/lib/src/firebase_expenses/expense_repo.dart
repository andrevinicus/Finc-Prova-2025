import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {

  Future<void> createExpense(ExpenseEntity expense);
  Future<List<ExpenseEntity>> getExpenses(String userId);

}
