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
  final GeminiService geminiService;
  final ValueNotifier<bool> isTypingNotifier;

  ChatQuickActions({
    super.key,
    required this.userId,
    required this.onMessageGenerated,
    required this.expenseRepo,
    required this.incomeRepo,
    required this.categoryMap,
    required this.geminiService,
    required this.isTypingNotifier, // 🔹 Passar notifier do AI typing
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
                  print("🖱️ Clique detectado em ${cat.name}");

                  // 1️⃣ Mostra no chat como mensagem do usuário
                  onMessageGenerated("Gastos em ${cat.name}", sender: "user");

                  // 2️⃣ Ativa "digitando..."
                  isTypingNotifier.value = true;

                  // 3️⃣ Pega os lançamentos da categoria
                  final expenses =
                      await _getExpensesByCategory(cat.categoryId.toString());

                  // 4️⃣ Gera o prompt detalhado para Gemini
                  final prompt =
                      ChatPrompts.gastosDetalhadosPorCategoria(cat.name, expenses);
                  print("Prompt enviado ao Gemini:\n$prompt");

                  try {
                    // 5️⃣ Envia somente o prompt
                    final geminiResponse =
                        await geminiService.sendMessage(prompt);

                    // 6️⃣ Mostra a resposta do AI
                    onMessageGenerated(geminiResponse, sender: "ai");
                  } catch (e) {
                    onMessageGenerated(
                        "Erro ao conectar com o Gemini.", sender: "ai");
                  } finally {
                    // 7️⃣ Desativa "digitando..."
                    isTypingNotifier.value = false;
                  }
                },
              ),
            ),
          ),
          // Bolha de receita total
          ActionBubble(
            label: "Receita Total",
            onTap: () async {
              print("🖱️ Clique detectado em Receita Total");

              // Mostra no chat como usuário
              onMessageGenerated("Receita Total", sender: "user");

              // Ativa "digitando..."
              isTypingNotifier.value = true;

              final total = await _getTotalReceita();
              final promptExterno = ChatPrompts.receitaTotal(total);
              print("Prompt enviado ao Gemini:\n$promptExterno");

              try {
                final geminiResponse =
                    await geminiService.sendMessage(promptExterno);

                onMessageGenerated(geminiResponse, sender: "ai");
              } catch (e) {
                onMessageGenerated("Erro ao conectar com o Gemini.", sender: "ai");
              } finally {
                isTypingNotifier.value = false;
              }
            },
          ),
        ],
      ),
    );
  }

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

  Future<double> _getTotalReceita() async {
    try {
      final incomes = await incomeRepo.getIncomes(userId);
      return incomes.fold<double>(0, (sum, i) => sum + i.amount);
    } catch (_) {
      return 0.0;
    }
  }
}
