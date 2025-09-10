import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/AIChatScreen/bloc_chat/chat_bloc.dart';
import 'package:finc/screens/AIChatScreen/bloc_chat/chat_event.dart';
import 'package:finc/screens/AIChatScreen/bloc_chat/chat_state.dart';

Future<void> showChatHistoryModalBloc({
  required BuildContext context,
  required ChatBloc chatBloc,
  required String userId,
  required void Function(String chatId) onChatSelected,
}) async {
  // Dispara o evento para carregar histórico
  chatBloc.add(LoadUserChats(userId: userId));

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      // Passa o bloc existente para dentro do modal
      return BlocProvider.value(
        value: chatBloc,
        child: SizedBox(
          height: MediaQuery.of(modalContext).size.height * 0.5,
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              // Loading
              if (state is ChatHistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Lista de chats carregada
              if (state is ChatHistoryLoaded) {
                final chatIds = state.chatIds;
                if (chatIds.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "📄 Nenhum histórico de chat encontrado",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: chatIds.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final chatId = chatIds[index];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline,
                          color: Colors.blueAccent),
                      title: Text("Chat $chatId"),
                      onTap: () {
                        Navigator.of(context).pop(); // Fecha o modal
                        onChatSelected(chatId);       // Notifica seleção
                      },
                    );
                  },
                );
              }

              // Erro
              if (state is ChatError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '❌ Erro ao carregar histórico: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Estado inicial ou outros
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
  );
}
