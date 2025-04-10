import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');
  final expenseCollection = FirebaseFirestore.instance.collection('expenses');

  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

 @override
Future<List<Category>> getCategory(String userId) async {
  try {
    final snapshot = await categoryCollection
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((e) {
      return Category.fromEntity(
        CategoryEntity.fromDocument(e.data()),
      );
    }).toList();
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    try {
      final snapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((e) {
        return Expense.fromEntity(
          ExpenseEntity.fromDocument(e.data()),
        );
      }).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
