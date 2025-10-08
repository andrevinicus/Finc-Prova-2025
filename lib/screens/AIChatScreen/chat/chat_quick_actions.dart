import 'package:finc/screens/AIChatScreen/gemini_config/gemini_service.dart';
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
  final GeminiService geminiService; // agora obrigatório

  ChatQuickActions({
    super.key,
    required this.userId,
    required this.onMessageGenerated,
    required this.expenseRepo,
    required this.incomeRepo,
    required this.categoryMap,
    required this.geminiService, // recebe do pai
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
          // Bolhas de categoria
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionBubble(
                label: "Gastos em ${cat.name}",
                onTap: () async {
                  final expenses = await _getExpensesByCategory(cat.categoryId.toString());

                  // Gera prompt detalhado com gastos
                  final enrichedPrompt = ChatPrompts.gastosDetalhadosPorCategoria(cat.name, expenses);
                  debugPrint("Prompt enviado para Gemini: $enrichedPrompt");

                  // Mostra no chat a mensagem do usuário (opcional)
                  onMessageGenerated("Gastos em ${cat.name}", sender: "user");

                  try {
                    final geminiResponse = await geminiService.sendMessage(enrichedPrompt);
                    onMessageGenerated(geminiResponse, sender: "ai");
                  } catch (e) {
                    onMessageGenerated("Erro ao conectar com o Gemini.", sender: "ai");
                  }
                },
              ),
            ),
          ),
          // Bolha de receita total
          ActionBubble(
            label: "Receita Total",
            onTap: () async {
              onMessageGenerated("Receita Total", sender: "user");

              final total = await _getTotalReceita();
              final enrichedPrompt = ChatPrompts.receitaTotal(total);

              try {
                final geminiResponse = await geminiService.sendMessage(enrichedPrompt);
                onMessageGenerated(geminiResponse, sender: "ai");
              } catch (e) {
                onMessageGenerated("Erro ao conectar com o Gemini.", sender: "ai");
              }
            },
          ),
        ],
      ),
    );
  }

  // Pega todos os lançamentos de uma categoria
  Future<List<Expense>> _getExpensesByCategory(String categoryId) async {
    try {
      final expenseEntities = await expenseRepo.getExpenses(userId);

      return expenseEntities
          .where((e) => e.categoryId.toString() == categoryId)
          .map((e) => Expense(
                id: e.expenseId.toString(),
                type: e.type,
                userId: e.userId,
                amount: e.amount.toDouble(),
                description: e.description,
                categoryId: e.categoryId,
                date: e.date,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Pega o total de receita
  Future<double> _getTotalReceita() async {
    try {
      final incomes = await incomeRepo.getIncomes(userId);
      return incomes.fold<double>(0, (sum, i) => sum + i.amount);
    } catch (_) {
      return 0.0;
    }
  }
}
