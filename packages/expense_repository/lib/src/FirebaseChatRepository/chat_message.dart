import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message_entity.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromEntity(ChatMessageEntity entity) {
    return ChatMessage(
      sender: entity.sender,
      text: entity.text,
      timestamp: entity.timestamp.toDate(),
    );
  }

  ChatMessageEntity toEntity({required String chatId}) {
    return ChatMessageEntity(
      chatId: chatId,
      sender: sender,
      text: text,
      timestamp: Timestamp.fromDate(timestamp),
    );
  }
}
