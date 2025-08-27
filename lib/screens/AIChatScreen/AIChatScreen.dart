import 'package:flutter/material.dart';
import './gemini_service.dart';
import './chat_message_widget.dart';
import './typing_indicator.dart';

// Repositórios Firebase
import 'package:expense_repository/expense_repository.dart';

class AIChatScreen extends StatefulWidget {
  final String userId;
  final String userName; // novo parâmetro

  const AIChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}
class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  final List<Map<String, String>> messages = [];
  bool isTyping = false;

  // Repositórios Firebase
  final FirebaseExpenseRepo expenseRepo = FirebaseExpenseRepo();
  final FirebaseIncomeRepo incomeRepo = FirebaseIncomeRepo();

  @override
  void initState() {
    super.initState();
      print("UserId recebido no AIChatScreen: ${widget.userId}");
  print("UserName recebido no AIChatScreen: ${widget.userName}");
    // Mensagem de boas-vindas
    Future.delayed(Duration.zero, () {
      setState(() {
        messages.add({
          "sender": "ai",
          "text": "Bom dia, ${widget.userName}! 👋\nComo posso te ajudar hoje?"
        });
      });
      _scrollToBottom();
    });
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Apenas envia para IA geral
      final aiResponse = await _geminiService.sendMessage(text);
      setState(() {
        messages.add({"sender": "ai", "text": aiResponse});
        isTyping = false;
      });
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "ai",
          "text": "Erro ao conectar com o Gemini."
        });
        isTyping = false;
      });
    }

    _scrollToBottom();
  }

  // Botões que calculam valores, estilizados como bolhas de chat
  Widget _buildQuickActions() {
    return FutureBuilder<List<ExpenseEntity>>(
      future: expenseRepo.getExpenses(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final lancamentos = snapshot.data!;
        if (lancamentos.isEmpty) {
          return const SizedBox(
            height: 50,
            child: Center(child: Text("Nenhuma despesa encontrada.")),
          );
        }

        // Extrai os nomes das categorias como Strings
        final categorias = lancamentos.map((l) => l.category.name).toSet().toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Botões dinâmicos para cada categoria
              ...categorias.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildActionBubble("Gastos em $cat", () async {
                  final total = await _getTotalByCategory(cat); // cat já é String
                  setState(() {
                    messages.add({"sender": "ai", "text": total});
                  });
                  _scrollToBottom();
                }),
              )),
              // Botão fixo para receita total
              _buildActionBubble("Receita Total", () async {
                final result = await _getTotalReceita();
                setState(() {
                  messages.add({"sender": "ai", "text": result});
                });
                _scrollToBottom();
              }),
            ],
          ),
        );
      },
    );
  }




  Widget _buildActionBubble(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

Future<String> _getTotalByCategory(String category) async {
  try {
    final lancamentos = await expenseRepo.getExpenses(widget.userId);
    print("Lançamentos recebidos do Firebase para ${widget.userId}:");
    for (var l in lancamentos) {
      print("Categoria: ${l.category}, Valor: ${l.amount}");
    }

    final despesasCategoria = lancamentos.where((l) => l.category == category).toList();
    final total = despesasCategoria.fold<double>(0, (sum, l) => sum + (l.amount));

    print("Total para categoria '$category': $total");
    return "Você gastou R\$${total.toStringAsFixed(2)} em $category.";
  } catch (e) {
    print("Erro ao buscar gastos por categoria: $e");
    return "Não foi possível calcular os gastos em $category.";
  }
}

Future<String> _getTotalReceita() async {
  try {
    final receitas = await incomeRepo.getIncomes(widget.userId);
    print("Receitas recebidas do Firebase para ${widget.userId}:");
    for (var r in receitas) {
      print("Valor: ${r.amount}");
    }

    final totalReceita = receitas.fold<double>(0, (sum, r) => sum + (r.amount));
    print("Total de receita: $totalReceita");

    return "Sua receita total é R\$${totalReceita.toStringAsFixed(2)}.";
  } catch (e) {
    print("Erro ao buscar receita: $e");
    return "Não foi possível calcular a receita total.";
  }
}


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistente IA"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return const TypingIndicator();
                }
                final msg = messages[index];
                return ChatMessageWidget(
                  sender: msg["sender"]!,
                  text: msg["text"]!,
                );
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: "Escreva sua mensagem...",
                filled: true,
                fillColor:
                    theme.colorScheme.surfaceVariant.withOpacity(0.15),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
