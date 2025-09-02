import 'package:flutter/material.dart';
import 'chat/chat_message_list.dart';
import 'chat/chat_input_bar.dart';
import 'chat/chat_quick_actions.dart';
import 'gemini_config/gemini_service.dart';
import 'package:expense_repository/expense_repository.dart';

class AIChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AIChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final FirebaseExpenseRepo expenseRepo = FirebaseExpenseRepo();
  final FirebaseIncomeRepo incomeRepo = FirebaseIncomeRepo();

  final List<Map<String, String>> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _addMessage("Bom dia, ${widget.userName}! 👋\nComo posso te ajudar hoje?", sender: "ai");
  }

void _addMessage(String text, {String sender = "ai"}) {
  if (sender == "ai" && text.startsWith("O usuário pediu detalhes")) {
    // não adiciona ao chat, só envia para o Gemini
    return;
  }

  setState(() {
    messages.add({"sender": sender, "text": text});
  });
  _scrollToBottom();
}


  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    _addMessage(text, sender: "user");
    _controller.clear();

    setState(() => isTyping = true);

    try {
      final aiResponse = await _geminiService.sendMessage(text);
      _addMessage(aiResponse, sender: "ai");
    } catch (_) {
      _addMessage("Erro ao conectar com o Gemini.", sender: "ai");
    }

    setState(() => isTyping = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Assistente IA"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              messages: messages,
              isTyping: isTyping,
              controller: _scrollController,
            ),
          ),
          FutureBuilder<List<Category>>(
            future: FirebaseCategoryRepository().getCategories(widget.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final categoryMap = {for (var c in snapshot.data!) c.categoryId.toString(): c};

              return ChatQuickActions(
                userId: widget.userId,
                expenseRepo: expenseRepo,
                incomeRepo: incomeRepo,
                categoryMap: categoryMap,
                onMessageGenerated: (text, {String sender = "ai"}) async {
                  _addMessage(text, sender: sender);

                  // Só envia para a IA se for mensagem do usuário
                  if (sender == "user") {
                    setState(() => isTyping = true);
                    try {
                      final aiResponse = await _geminiService.sendMessage(text);
                      _addMessage(aiResponse, sender: "ai");
                    } catch (_) {
                      _addMessage("Erro ao conectar com o Gemini.", sender: "ai");
                    }
                    setState(() => isTyping = false);
                  }
                },
              );
            },
          ),
          ChatInputBar(controller: _controller, onSend: sendMessage),
        ],
      ),
    );
  }
}
