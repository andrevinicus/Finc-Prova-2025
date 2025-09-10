import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';


abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}
// 🔹 Novos estados para histórico de chats
class ChatHistoryLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatHistoryLoaded extends ChatState {
  final List<String> chatIds;

  const ChatHistoryLoaded(this.chatIds);

  @override
  List<Object?> get props => [chatIds];
}

