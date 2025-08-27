import 'package:flutter/material.dart';
import './gemini_service.dart';
import './chat_message_widget.dart';
import './typing_indicator.dart';

class AIChatScreen extends StatefulWidget {
  final String userId;
  const AIChatScreen({super.key, required this.userId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  final List<Map<String, String>> messages = []; // {"sender": "user"/"ai", "text": "..."}
  bool isTyping = false;

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    // Adiciona mensagem do usuário
    setState(() {
      messages.add({"sender": "user", "text": text});
      isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final aiResponse = await _geminiService.sendMessage(text);
      setState(() {
        messages.add({"sender": "ai", "text": aiResponse});
        isTyping = false;
      });
    } catch (_) {
      setState(() {
        messages.add({"sender": "ai", "text": "Erro ao conectar com o Gemini."});
        isTyping = false;
      });
    }
    _scrollToBottom();
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
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
