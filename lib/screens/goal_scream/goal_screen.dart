
import 'package:finc/screens/goal_scream/bloc/bloc_goal.dart';
import 'package:finc/screens/goal_scream/bloc/events_goal.dart';
import 'package:finc/screens/goal_scream/bloc/states_goal.dart';
import 'package:finc/screens/goal_scream/widgets/goal_card.dart';
import 'package:finc/screens/goal_scream/widgets/goal_list_item.dart';
import 'package:finc/screens/goal_scream/widgets/modal_add_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class GoalScreen extends StatefulWidget {
  final String userId;

  const GoalScreen({super.key, required this.userId});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  int? _expandedIndex;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    // Dispara o carregamento inicial das metas
    context.read<GoalBloc>().add(LoadGoals(widget.userId));
  }

  void _toggleExpand(int index) {
    if (_itemKeys.isEmpty || index >= _itemKeys.length) return;

    setState(() {
      _expandedIndex = (_expandedIndex == index) ? null : index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_expandedIndex != null && _expandedIndex! < _itemKeys.length) {
        final contextKey = _itemKeys[_expandedIndex!].currentContext;
        if (contextKey != null) {
          Scrollable.ensureVisible(
            contextKey,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
        }
      }
    });
  }

void _showAddGoalModal() {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true, // 🔹 evita empurrar o modal para cima
      child: AddGoalModal(
        goalBloc: context.read<GoalBloc>(),
        onAddGoal: (goal) {
          print('Meta adicionada: ${goal.title}');
        },
      ),
    ),
  );
}



  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Metas Financeiras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Meta',
            onPressed: _showAddGoalModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: BlocBuilder<GoalBloc, GoalState>(
            builder: (context, state) {
              if (state is GoalLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is GoalLoaded) {
                final goals = state.goals;
                _itemKeys.clear();
                _itemKeys.addAll(List.generate(goals.length, (_) => GlobalKey()));

                return Column(
                  children: [
                    // Cards horizontais
                    SizedBox(
                      height: 215,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: goals.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () => _toggleExpand(index),
                            child: GoalCard(goal: goals[index]),
                          ),
                        ),
                      ),
                    ),
                    // Lista vertical detalhada
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount: goals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return GoalListItem(
                              key: _itemKeys[index],
                              goal: goals[index],
                              isExpanded: _expandedIndex == index,
                              onTap: () => _toggleExpand(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              } else if (state is GoalError) {
                return Center(child: Text('Erro: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
