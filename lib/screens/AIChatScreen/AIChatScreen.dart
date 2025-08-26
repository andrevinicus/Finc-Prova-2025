import 'package:flutter/material.dart';
import 'dart:async';

class AIChatScreen extends StatefulWidget {
  final String userId;
  const AIChatScreen({super.key, required this.userId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = []; // {"sender": "user"/"ai", "text": "..."}
  bool isTyping = false;

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    // Adiciona a mensagem do usuário
    setState(() {
      messages.add({"sender": "user", "text": text});
    });
    _controller.clear();
    _scrollToBottom();

    // Simula a IA digitando
    setState(() => isTyping = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        messages.add({"sender": "ai", "text": "Resposta simulada para: '$text'"});
        isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(Map<String, String> msg, ThemeData theme) {
    final isAI = msg["sender"] == "ai";
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            gradient: isAI
                ? LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade400])
                : null,
            color: isAI ? null : theme.colorScheme.primary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isAI ? 4 : 16),
              bottomRight: Radius.circular(isAI ? 16 : 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              )
            ],
          ),
          child: Text(
            msg["text"]!,
            style: TextStyle(
              color: isAI ? Colors.white : Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade400]),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Text("Digitando...", style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
      ),
    );
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
                  return _buildTypingIndicator();
                }
                final msg = messages[index];
                return _buildMessage(msg, theme);
              },
            ),
          ),
          Container(
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
          ),
        ],
      ),
    );
  }
}
