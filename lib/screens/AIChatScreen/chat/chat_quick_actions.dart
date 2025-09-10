import 'package:finc/screens/AIChatScreen/prompt/chat_prompts.dart';
import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import 'action_bubble.dart';

class ChatQuickActions extends StatelessWidget {
  final String userId;
  final Function(String text, {String sender}) onMessageGenerated;
  final FirebaseExpenseRepo expenseRepo;
  final FirebaseIncomeRepo incomeRepo;
  final Map<String, Category> categoryMap;

  const ChatQuickActions({
    super.key,
    required this.userId,
    required this.onMessageGenerated,
    required this.expenseRepo,
    required this.incomeRepo,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = categoryMap.values.toList();

    if (categories.isEmpty) {
      return const SizedBox(
        height: 50,
        child: Center(child: Text("Nenhuma categoria encontrada.")),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionBubble(
                label: "Gastos em ${cat.name}",
                onTap: () async {
                  // Mostra no chat como se fosse o usuário
                  onMessageGenerated("Gastos em ${cat.name}", sender: "user");

                  // Calcula o total e envia prompt interno para IA
                  final total = await _getTotalByCategory(cat.categoryId.toString());
                  final enrichedPrompt = ChatPrompts.gastosPorCategoria(cat.name, total);

                  onMessageGenerated(enrichedPrompt, sender: "ai");
                },
              ),
            ),
          ),
          ActionBubble(
            label: "Receita Total",
            onTap: () async {
              onMessageGenerated("Receita Total", sender: "user");

              final total = await _getTotalReceita();
              final enrichedPrompt = ChatPrompts.receitaTotal(total);

              onMessageGenerated(enrichedPrompt, sender: "ai");
            },
          ),
        ],
      ),
    );
  }

  Future<double> _getTotalByCategory(String categoryId) async {
    try {
      final expenses = await expenseRepo.getExpenses(userId);
      final filtered = expenses.where((e) => e.categoryId.toString() == categoryId).toList();
      return filtered.fold<double>(0, (sum, e) => sum + e.amount);
    } catch (_) {
      return 0.0;
    }
  }

  Future<double> _getTotalReceita() async {
    try {
      final incomes = await incomeRepo.getIncomes(userId);
      return incomes.fold<double>(0, (sum, i) => sum + i.amount);
    } catch (_) {
      return 0.0;
    }
  }
}
