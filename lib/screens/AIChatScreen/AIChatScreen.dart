import 'package:finc/screens/AIChatScreen/ChatDrawer/chat_drawer.dart';
import 'package:finc/screens/AIChatScreen/prompt/chat_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'chat/chat_message_list.dart';
import 'chat/chat_input_bar.dart';
import 'chat/chat_quick_actions.dart';
import 'gemini_config/gemini_service.dart';
import 'bloc_chat/chat_bloc.dart';
import 'bloc_chat/chat_event.dart';
import 'bloc_chat/chat_state.dart';

class AIChatScreenWrapper extends StatelessWidget {
  final String userId;
  final String userName;

  const AIChatScreenWrapper({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final chatRepo = FirebaseChatRepository();

    return BlocProvider(
      create: (_) => ChatBloc(repository: chatRepo),
      child: AIChatScreen(userId: userId, userName: userName),
    );
  }
}

class AIChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AIChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final FirebaseExpenseRepo expenseRepo = FirebaseExpenseRepo();
  final FirebaseIncomeRepo incomeRepo = FirebaseIncomeRepo();

  late ChatBloc _chatBloc;
  late final String chatId;
  final FirebaseChatRepository _chatRepo = FirebaseChatRepository();

  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(repository: _chatRepo);

    // Inicializa o estado com lista vazia
    // ignore: invalid_use_of_visible_for_testing_member
    _chatBloc.emit(ChatLoaded([]));
    chatId = DateTime.now().millisecondsSinceEpoch.toString();
    // Adiciona a mensagem de boas-vindas
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      sender: "ai",
      text: "Bom dia, ${widget.userName}! 👋\nComo posso te ajudar hoje?",
      timestamp: DateTime.now(),
    );

    _chatBloc.add(
      SendMessage(
        userId: widget.userId,
        chatId: chatId,
        message: welcomeMessage,
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    final message = ChatMessage(
      sender: "user",
      text: text,
      timestamp: DateTime.now(),
    );

    _chatBloc.add(
      SendMessage(userId: widget.userId, chatId: chatId, message: message),
    );
    _controller.clear();
    setState(() => isTyping = true);

    try {
      final aiResponseText = await _geminiService.sendMessage(text);
      final aiMessage = ChatMessage(
        sender: "ai",
        text: aiResponseText,
        timestamp: DateTime.now(),
      );
      _chatBloc.add(
        SendMessage(userId: widget.userId, chatId: chatId, message: aiMessage),
      );
    } catch (_) {
      final errorMessage = ChatMessage(
        sender: "ai",
        text: "Erro ao conectar com o Gemini.",
        timestamp: DateTime.now(),
      );
      _chatBloc.add(
        SendMessage(
          userId: widget.userId,
          chatId: chatId,
          message: errorMessage,
        ),
      );
    }

    setState(() => isTyping = false);
  }

Future<bool> _onWillPop() async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Sair do chat"),
      content: const Text("Deseja salvar este chat antes de sair?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop("no"),
          child: const Text("Não"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop("yes"),
          child: const Text("Sim"),
        ),
      ],
    ),
  );

  if (result == "yes") {
    final state = _chatBloc.state;
    if (state is ChatLoaded) {
      // Mostra modal de salvando
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Salvando chat..."),
              ],
            ),
          ),
        ),
      );

      // Salva mensagens
      for (var message in state.messages) {
        await _chatRepo.saveMessage(
          widget.userId,
          chatId,
          message.toEntity(chatId: chatId),
        );
      }

      // Fecha modal de salvando
      Navigator.of(context, rootNavigator: true).pop();

      // Volta para a home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    return false;
  } else if (result == "no") {
    // Apenas volta para a home sem salvar
    Navigator.of(context).popUntil((route) => route.isFirst);
    return false;
  }

  return false;
}


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Assistente IA"),
            centerTitle: true,
            leading: const BackButton(),
            actions: [
              Builder(
                builder:
                    (contextWithBloc) => IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        showChatHistoryModalBloc(
                          context: contextWithBloc,
                          chatBloc: _chatBloc, // <--- passa explicitamente
                          userId: widget.userId,
                          onChatSelected: (chatId) {
                            _chatBloc.add(
                              LoadMessages(
                                userId: widget.userId,
                                chatId: chatId,
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoaded) {
                      // Aguarda o frame ser renderizado antes de rolar
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });

                      return ChatMessageList(
                        messages:
                            state.messages
                                .map(
                                  (m) => {"sender": m.sender, "text": m.text},
                                )
                                .toList(),
                        isTyping: isTyping,
                        controller: _scrollController,
                      );
                    } else if (state is ChatError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              FutureBuilder<List<Category>>(
                future: FirebaseCategoryRepository().getCategories(
                  widget.userId,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final categoryMap = {
                    for (var c in snapshot.data!) c.categoryId.toString(): c,
                  };
                  return ChatQuickActions(
                    userId: widget.userId,
                    expenseRepo: expenseRepo,
                    incomeRepo: incomeRepo,
                    categoryMap: categoryMap,
                    onMessageGenerated: (text, {String sender = "user"}) async {
                      if (sender == "user") {
                        final userMessage = ChatMessage(
                          sender: "user",
                          text: text,
                          timestamp: DateTime.now(),
                        );
                        _chatBloc.add(
                          SendMessage(
                            userId: widget.userId,
                            chatId: chatId,
                            message: userMessage,
                          ),
                        );

                        setState(() => isTyping = true);

                        try {
                          final aiPrompt = ChatPrompts.gastosPorCategoria(
                            "Categoria Exemplo",
                            100.0,
                          );
                          final aiResponse = await _geminiService.sendMessage(
                            aiPrompt,
                          );

                          final aiMessage = ChatMessage(
                            sender: "ai",
                            text: aiResponse,
                            timestamp: DateTime.now(),
                          );
                          _chatBloc.add(
                            SendMessage(
                              userId: widget.userId,
                              chatId: chatId,
                              message: aiMessage,
                            ),
                          );
                        } catch (_) {
                          final errorMessage = ChatMessage(
                            sender: "ai",
                            text: "Erro ao conectar com o Gemini.",
                            timestamp: DateTime.now(),
                          );
                          _chatBloc.add(
                            SendMessage(
                              userId: widget.userId,
                              chatId: chatId,
                              message: errorMessage,
                            ),
                          );
                        }

                        setState(() => isTyping = false);
                      }
                    },
                  );
                },
              ),
              ChatInputBar(controller: _controller, onSend: sendMessage),
            ],
          ),
        ),
      ),
    );
  }
}
