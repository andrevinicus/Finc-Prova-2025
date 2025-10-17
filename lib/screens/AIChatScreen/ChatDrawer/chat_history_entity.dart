import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';


class ChatHistoryEntity {
  final String site;
  final Timestamp savedAt;
  final List<ChatMessageEntity> messages;

  ChatHistoryEntity({
    required this.site,
    required this.savedAt,
    required this.messages,
  });

  Map<String, dynamic> toDocument() {
    return {
      'site': site,
      'savedAt': savedAt,
      'messages': messages.map((m) => m.toDocument()).toList(),
    };
  }

  factory ChatHistoryEntity.fromDocument(Map<String, dynamic> doc) {
    var messagesFromDoc = (doc['messages'] as List)
        .map((m) => ChatMessageEntity.fromDocument(m as Map<String, dynamic>))
        .toList();

    return ChatHistoryEntity(
      site: doc['site'] as String,
      savedAt: doc['savedAt'] as Timestamp,
      messages: messagesFromDoc,
    );
  }
}
