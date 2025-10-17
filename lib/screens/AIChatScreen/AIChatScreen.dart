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
import 'ChatModalHistorico/chat_modal.dart';

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

  late final ChatBloc _chatBloc;
  late final String chatId;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    chatId = DateTime.now().millisecondsSinceEpoch.toString();

    // Primeiro carrega o chat vazio
    _chatBloc.add(LoadMessages(userId: widget.userId, chatId: chatId));

    // Aguarda o primeiro ChatLoaded para enviar a mensagem de boas-vindas
    _chatBloc.stream.firstWhere((state) => state is ChatLoaded).then((_) {
      _sendAIMessage(
        "Bom dia, ${widget.userName}! 👋\nComo posso te ajudar hoje?",
        sender: "ai",
      );
    });
  }

  Future<void> _sendAIMessage(String text, {String sender = "ai"}) async {
    final message = ChatMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
    );

    _chatBloc.add(
      SendMessage(
        userId: widget.userId,
        chatId: chatId,
        message: message,
        source: sender == "ai" ? "Gemini" : "InputBar",
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    _controller.clear();
    setState(() => isTyping = true);

    _sendAIMessage(text, sender: "user");

    try {
      final aiResponse = await _geminiService.sendMessage(text);
      _sendAIMessage(aiResponse, sender: "ai");
    } catch (e, st) {
      debugPrint("Erro Gemini: $e\n$st");
      _sendAIMessage("Erro ao conectar com o Gemini.", sender: "ai");
    }

    setState(() => isTyping = false);
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
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
          builder:
              (_) => const AlertDialog(
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

        // Dispara evento SaveChat
        _chatBloc.add(SaveChat(userId: widget.userId, chatId: chatId));

        // Fecha modal
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Volta para a home
      Navigator.of(context).popUntil((route) => route.isFirst);
      return false;
    } else if (result == "no") {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
                        repository: _chatBloc.repository,
                        userId: widget.userId,
                        onChatSelected: (chatId) {
                          _chatBloc.add(
                            LoadMessages(userId: widget.userId, chatId: chatId),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoaded) {
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
                    geminiService: _geminiService,
                    onMessageGenerated: _sendAIMessage,
                    isTypingNotifier: ValueNotifier<bool>(isTyping),
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
