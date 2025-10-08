import 'package:expense_repository/expense_repository.dart';

abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String userId;
  final String chatId;

  LoadMessages({required this.userId, required this.chatId});
}

class SendMessage extends ChatEvent {
  final String userId;
  final String chatId;
  final ChatMessage message;

  // ✅ Campo opcional para identificar a origem da mensagem
  final String? source;

  SendMessage({
    required this.userId,
    required this.chatId,
    required this.message,
    this.source,
  });
}

class SaveChat extends ChatEvent {
  final String userId;
  final String chatId;

  SaveChat({required this.userId, required this.chatId});
}

class LoadUserChats extends ChatEvent {
  final String userId;
  LoadUserChats({required this.userId});
}
