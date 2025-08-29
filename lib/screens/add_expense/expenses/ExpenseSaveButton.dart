import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_repository/expense_repository.dart';

class ExpenseSaveButton extends StatelessWidget {
  final String amountText;
  final String? selectedBankId;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final String description;
  final File? selectedImage;
  final Future<String?> Function(File) uploadImage;

  const ExpenseSaveButton({
    super.key,
    required this.amountText,
    required this.selectedBankId,
    required this.selectedCategory,
    required this.selectedDate,
    required this.description,
    required this.selectedImage,
    required this.uploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context);
        } else if (state is CreateExpenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateExpenseLoading;

        return FloatingActionButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    // 🔹 Validação de valor
                    if (amountText.isEmpty ||
                        double.tryParse(amountText) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Informe um valor válido.'),
                        ),
                      );
                      return;
                    }

                    // 🔹 Validação de categoria
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione uma categoria.'),
                        ),
                      );
                      return;
                    }

                    // 🔹 Criação do objeto Expense
                    final uuid = Uuid();
                    final userId = FirebaseAuth.instance.currentUser!.uid;
                    String? imageId;

                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione uma categoria.'),
                        ),
                      );
                      return;
                    }

                    // Copia para variável local
                    final category = selectedCategory;

                    // Agora `category` é promovida a não-nula
                    final expense = Expense(
                      id: uuid.v4(),
                      categoryId: category!.categoryId, // sem precisar de !
                      amount: double.parse(amountText),
                      description: description,
                      date: selectedDate,
                      userId: userId,
                      type: 'expense',
                      bankId: selectedBankId,
                      imageId: imageId,
                    );

                    // 🔹 Salva a despesa via Bloc
                    context.read<CreateExpenseBloc>().add(
                      CreateExpenseSubmitted(expense),
                    );

                    // 🔹 Atualiza totalExpenses da categoria no Firestore
                    final categoryRef = FirebaseFirestore.instance
                        .collection("categories")
                        .doc(category!.categoryId);

                    await FirebaseFirestore.instance.runTransaction((
                      transaction,
                    ) async {
                      final snapshot = await transaction.get(categoryRef);

                      if (!snapshot.exists) return;

                      final currentTotal =
                          (snapshot['totalExpenses'] ?? 0) as num;
                      final newTotal = currentTotal + expense.amount;

                      transaction.update(categoryRef, {
                        "totalExpenses": newTotal,
                      });
                    });
                  },
          backgroundColor: Colors.blueAccent,
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.check, size: 30, color: Colors.white),
        );
      },
    );
  }
}
