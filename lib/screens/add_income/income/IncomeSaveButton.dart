import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_repository/expense_repository.dart';

import '../blocs/create_expense_bloc/create_income_bloc.dart';

class IncomeSaveButton extends StatelessWidget {
  final String amountText;
  final Category? selectedCategory;
  final DateTime selectedDate;
  final String description;
  final String? selectedBankId;
  final File? selectedImage;
  final Future<String?> Function(File) uploadImage;

  const IncomeSaveButton({
    super.key,
    required this.amountText,
    required this.selectedCategory,
    required this.selectedDate,
    required this.description,
    required this.selectedBankId,
    required this.selectedImage,
    required this.uploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<CreateIncomeBloc, CreateIncomeState>(
        listener: (context, state) {
          if (state is CreateIncomeSuccess) {
            Navigator.pop(context);
          } else if (state is CreateIncomeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateIncomeLoading;
      
          return FloatingActionButton(
            onPressed: isLoading
                ? null
                : () async {
                    // 🔹 Validação de valor
                    if (amountText.isEmpty ||
                        double.tryParse(amountText) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Informe um valor válido.')),
                      );
                      return;
                    }
      
                    // 🔹 Validação de categoria
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecione uma categoria.')),
                      );
                      return;
                    }
      
                    final uuid = const Uuid();
                    final userId = FirebaseAuth.instance.currentUser!.uid;
      
                    String? imageId;
                    if (selectedImage != null) {
                      imageId = await uploadImage(selectedImage!);
                    }
      
                    final income = Income(
                      id: uuid.v4(),
                      categoryId: selectedCategory!.categoryId,
                      amount: double.parse(amountText),
                      description: description,
                      date: selectedDate,
                      userId: userId,
                      type: 'income',
                      bankId: selectedBankId,
                      imageId: imageId,
                    );
      
                    context
                        .read<CreateIncomeBloc>()
                        .add(CreateIncomeSubmitted(income));
                  },
            backgroundColor: Colors.blueAccent,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check, size: 30, color: Colors.white),
          );
        },
      ),
    );
  }
}
