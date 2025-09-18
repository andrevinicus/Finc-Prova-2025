import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/AIChatScreen/bloc_chat/chat_bloc.dart';
import 'package:finc/screens/AIChatScreen/bloc_chat/chat_event.dart';
import 'package:finc/screens/AIChatScreen/bloc_chat/chat_state.dart';
import 'package:expense_repository/expense_repository.dart';

Future<void> showChatHistoryModalBloc({
  required BuildContext context,
  required ChatRepository repository,
  required String userId,
  required void Function(String chatId) onChatSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      return BlocProvider(
        create: (_) => ChatBloc(repository: repository)
          ..add(LoadUserChats(userId: userId)),
        child: SizedBox(
          height: MediaQuery.of(modalContext).size.height * 0.5,
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              // Loading do histórico
              if (state is ChatHistoryLoading || state is ChatInitial) {
                return const Center(child: CircularProgressIndicator());
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

              // Histórico carregado
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

                // Cria o future apenas uma vez
                final futureLastMessages = Future.wait(
                  chatIds.map((chatId) async {
                    final entities = await repository.getMessages(userId, chatId);
                    final messages = entities.map((e) => ChatMessage.fromEntity(e)).toList();
                    return messages.isNotEmpty ? messages.last.text : "Chat $chatId";
                  }),
                );

                return FutureBuilder<List<String>>(
                  future: futureLastMessages,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      // Loading central enquanto todas as últimas mensagens carregam
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lastMessages = snapshot.data!;

                    return ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: chatIds.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final chatId = chatIds[index];
                        final lastMessage = lastMessages[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            onChatSelected(chatId);
                          },
                        );
                      },
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
  );
}
