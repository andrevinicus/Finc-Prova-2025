import 'package:expense_repository/expense_repository.dart';

abstract class ChatEvent {}


// Evento para carregar mensagens de um chat
class LoadMessages extends ChatEvent {
  final String userId;
  final String chatId;

  LoadMessages({required this.userId, required this.chatId});
}

// Evento para enviar mensagem
class SendMessage extends ChatEvent {
  final String userId;
  final String chatId;
  final ChatMessage message;

  SendMessage({required this.userId, required this.chatId, required this.message});
}

// Evento para salvar chat
class SaveChat extends ChatEvent {
  final String userId;
  final String chatId;

  SaveChat({required this.userId, required this.chatId});
}

// ✅ Evento para carregar histórico de chats do usuário
class LoadUserChats extends ChatEvent {
  final String userId;
  LoadUserChats({required this.userId});
}
