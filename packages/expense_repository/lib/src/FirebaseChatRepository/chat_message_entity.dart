import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageEntity {
  final String chatId;      // 🔹 novo campo
  final String sender;
  final String text;
  final Timestamp timestamp;

  ChatMessageEntity({
    required this.chatId,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toDocument() {
    return {
      'chatId': chatId,       // 🔹 salvar no Firestore
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory ChatMessageEntity.fromDocument(Map<String, dynamic> doc) {
    return ChatMessageEntity(
      chatId: doc['chatId'] as String,   // 🔹 ler do Firestore
      sender: doc['sender'] as String,
      text: doc['text'] as String,
      timestamp: doc['timestamp'] as Timestamp,
    );
  }
}
