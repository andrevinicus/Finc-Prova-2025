import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<SaveChat>(_onSaveChat);

    // Handler para histórico de chats
    on<LoadUserChats>(_onLoadUserChats);
  }

  Future<void> _onLoadUserChats(
      LoadUserChats event, Emitter<ChatState> emit) async {
    print('🔄 Iniciando carregamento de histórico para userId: ${event.userId}');
    emit(ChatHistoryLoading());
    try {
      List<String> chatIds = [];
      if (repository is FirebaseChatRepository) {
        chatIds = await (repository as FirebaseChatRepository).getUserChats(event.userId);
        print('✅ Histórico carregado: ${chatIds.length} chats encontrados');
      } else {
        print('⚠ Repositório não suporta histórico');
        emit(ChatError("Repositório não suporta histórico"));
        return;
      }
      emit(ChatHistoryLoaded(chatIds));
    } catch (e, st) {
      print('❌ Erro ao buscar histórico: $e\n$st');
      emit(ChatError('Erro ao buscar histórico: $e'));
    }
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatState> emit) async {
    print('🔄 Carregando mensagens do chatId: ${event.chatId} para userId: ${event.userId}');
    emit(ChatLoading());
    try {
      final entities = await repository.getMessages(event.userId, event.chatId);
      final messages = entities.map((e) => ChatMessage.fromEntity(e)).toList();
      print('✅ Mensagens carregadas: ${messages.length}');
      emit(ChatLoaded(messages));
    } catch (e, st) {
      print('❌ Erro ao carregar mensagens: $e\n$st');
      emit(ChatError('Erro ao carregar mensagens: $e'));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) {
      print('⚠ Estado atual não é ChatLoaded, mensagem não enviada');
      return;
    }

    final currentMessages = List<ChatMessage>.from((state as ChatLoaded).messages)
      ..add(event.message);

    print('💬 Mensagem enviada: ${event.message.text} por ${event.message.sender}');
    emit(ChatLoaded(currentMessages));
  }

  Future<void> _onSaveChat(SaveChat event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) {
      print('⚠ Estado atual não é ChatLoaded, chat não salvo');
      return;
    }

    final messages = (state as ChatLoaded).messages;
    print('💾 Salvando chat ${event.chatId} com ${messages.length} mensagens para userId: ${event.userId}');
    try {
      for (var message in messages) {
        await repository.saveMessage(
          event.userId,
          event.chatId,
          message.toEntity(chatId: event.chatId),
        );
        print('✅ Mensagem salva: ${message.text}');
      }
      print('✅ Chat salvo com sucesso!');
    } catch (e, st) {
      print('❌ Erro ao salvar chat: $e\n$st');
      emit(ChatError('Erro ao salvar chat: $e'));
    }
  }
}
