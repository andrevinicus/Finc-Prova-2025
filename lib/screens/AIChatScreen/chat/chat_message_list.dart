import 'package:flutter/material.dart';
import 'chat_message_widget.dart';
import '../gemini_config/typing_indicator.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, String>> messages;
  final bool isTyping;
  final ScrollController controller;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isTyping,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == messages.length) return const TypingIndicator();
        final msg = messages[index];
        return ChatMessageWidget(sender: msg["sender"]!, text: msg["text"]!);
      },
    );
  }
}
