import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/goal_scream/bloc/bloc_goal.dart';
import 'package:finc/screens/goal_scream/bloc/events_goal.dart';
import 'package:finc/screens/goal_scream/bloc/states_goal.dart';
import 'package:finc/screens/goal_scream/widgets/add_transaction_modal.dart';
import 'package:finc/screens/goal_scream/widgets/animated_arrow.dart';
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
  bool _hasLoadedGoals = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedGoals) {
      context.read<GoalBloc>().add(LoadGoals(widget.userId));
      _hasLoadedGoals = true;
    }
  }

  void _toggleExpand(int index) {
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

  void _showAddGoalModal({Goal? goalToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: AddGoalModal(
          goalBloc: context.read<GoalBloc>(),
          goalToEdit: goalToEdit,
          onAddGoal: (goal) {
            if (goalToEdit == null) {
              print('Meta adicionada: ${goal.title}');
            } else {
              context.read<GoalBloc>().add(UpdateGoal(goal));
              print('Meta atualizada: ${goal.title}');
            }
          },
        ),
      ),
    );
  }

void _showAddTransactionModal(Goal goal) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: AddTransactionModal(
        goal: goal,
        onAdd: (transaction) {
          // ⚡ Aqui chamamos o evento correto que salva na subcoleção
          context.read<GoalBloc>().add(AddTransaction(goal, transaction));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lançamento adicionado!')),
          );
        },
      ),
    ),
  );
}


void _deleteGoal(Goal goal) {
  context.read<GoalBloc>().add(DeleteGoal(goal.id, widget.userId));
  // Não precisa chamar LoadGoals manualmente, o bloc já deve recarregar após deletar
}

  void _showGoalOptions(BuildContext context, Offset position, Goal goal) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem(value: 'Editar', child: Text('Editar')),
        const PopupMenuItem(value: 'Excluir', child: Text('Excluir')),
        const PopupMenuItem(value: 'AdicionarLançamento', child: Text('Adicionar Lançamento')),
      ],
    );

    switch (selected) {
      case 'Editar':
        _showAddGoalModal(goalToEdit: goal);
        break;
      case 'Excluir':
        _deleteGoal(goal);
        break;
      case 'AdicionarLançamento':
        _showAddTransactionModal(goal);
        break;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Metas Financeiras'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Adicionar Meta',
              onPressed: () => _showAddGoalModal(),
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
      
                  if (goals.isEmpty) {
                    return const Center(
                      child: Text(
                        'Clique no botão + para adicionar sua primeira meta!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }
      
                  if (_itemKeys.length != goals.length) {
                    _itemKeys.clear();
                    _itemKeys.addAll(List.generate(goals.length, (_) => GlobalKey()));
                  }
      
                  return Column(
                    children: [
                      SizedBox(
                        height: 215,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: () => _toggleExpand(index),
                                onLongPressStart: (details) {
                                  _showGoalOptions(context, details.globalPosition, goal);
                                },
                                child: GoalCard(goal: goal),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount: goals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return GestureDetector(
                              onTap: () => _toggleExpand(index),
                              onLongPressStart: (details) {
                                _showGoalOptions(context, details.globalPosition, goal);
                              },
                              child: GoalListItem(
                                key: _itemKeys[index],
                                goal: goal,
                                isExpanded: _expandedIndex == index,
                                onTap: () => _toggleExpand(index),
                              ),
                            );
                          },
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
        floatingActionButton: BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            if (state is GoalLoaded && state.goals.isEmpty) {
              return AnimatedArrow();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
