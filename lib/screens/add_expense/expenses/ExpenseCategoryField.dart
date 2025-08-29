import 'package:finc/screens/category/modal%20category/option_category_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';

class ExpenseCategoryField extends StatelessWidget {
  final String userId;
  final Category? selectedCategory;
  final Function(Category) onCategorySelected;

  const ExpenseCategoryField({
    super.key,
    required this.userId,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.flag, color: Colors.grey, size: 24),
      title: selectedCategory != null
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(selectedCategory!.color),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/${selectedCategory!.icon}.png',
                    width: 20,
                    height: 20,
                    color: Color(selectedCategory!.color),
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      selectedCategory!.name,
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Opções de Categoria',
                style: TextStyle(color: Colors.black54),
              ),
            ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () async {
        final resultado = await showModalBottomSheet<Category>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: CategoryOptionsModalExpense(userId: userId),
            );
          },
        );

        if (resultado != null) {
          onCategorySelected(resultado);
        }
      },
    );
  }
}
