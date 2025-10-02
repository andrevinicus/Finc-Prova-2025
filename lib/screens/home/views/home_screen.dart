import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/goal_scream/goal_screen.dart';
import 'package:finc/screens/home/views/home_screen/floating_action_buttons_menu.dart';
import 'package:finc/screens/home/views/home_screen/home_bottom_navbar.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_bloc.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/home/views/main_screen.dart';
import 'package:finc/screens/stats/stats.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;
  String userName = '';
  late String userId;
  bool _hasFetchedData = false;
  bool showActionButtons = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedData) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
        userName = user.displayName ?? '';
        context.read<GetFinancialDataBloc>().add(GetFinancialData(userId));
        _hasFetchedData = true;
      } else {
        userId = '';
        userName = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetFinancialDataBloc, GetFinancialDataState>(
      builder: (context, state) {
        if (state is GetFinancialDataSuccess) {
final pages = [
  BlocProvider(
    create: (context) => AnaliseLancamentoBloc(
      null, // argumento posicional obrigatório
      repository: FirebaseAnaliseLancamentoRepository(), // nomeado obrigatório
    )..add(LoadLancamentos(userId)),
    child: MainScreen(
      expenses: state.expenses,
      income: state.income,
      categoryMap: state.categoryMap,
    ),
  ),
  StatScreen(userId: userId),
  GoalScreen(userId: userId),
];


          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Stack(
                children: [
                  // 🔹 RefreshIndicator para pull-to-refresh
                  RefreshIndicator(
                    onRefresh: () async {
                      context.read<GetFinancialDataBloc>().add(
                        GetFinancialData(userId),
                      );
                    },
                    child: IndexedStack(
                      index: index,
                      children:
                          pages.map((page) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final availableHeight =
                                    constraints.maxHeight -
                                    kBottomNavigationBarHeight;

                                return SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height: availableHeight,
                                    child: page,
                                  ),
                                );
                              },
                            );
                          }).toList(),
                    ),
                  ),

                  // BottomNavigationBar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNavBarWidget(
                      currentIndex: index,
                      onTap: (value) {
                        if (value == 3) {
                          Navigator.pushNamed(
                            context,
                            '/aiChat',
                            arguments: {'userId': userId, 'userName': userName},
                          );
                        } else {
                          setState(() => index = value);
                        }
                      },
                    ),
                  ),

                  // Fundo escurecido quando FloatingActionButtonsMenu está aberto
                  if (showActionButtons)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showActionButtons = false;
                            _controller.reverse();
                          });
                        },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: 0.6,
                          child: Container(color: Colors.black),
                        ),
                      ),
                    ),

                  // FloatingActionButtonsMenu
                  FloatingActionButtonsMenu(
                    showActionButtons: showActionButtons,
                    controller: _controller,
                    screenWidth: MediaQuery.of(context).size.width,
                    userId: userId,
                    onClose: () {
                      setState(() {
                        showActionButtons = false;
                        _controller.reverse();
                      });
                    },
                  ),
                ],
              ),
            ),

            // FloatingActionButton principal
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                setState(() {
                  showActionButtons = !showActionButtons;
                  showActionButtons
                      ? _controller.forward()
                      : _controller.reverse();
                });
              },
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    showActionButtons ? Icons.close : Icons.add,
                    key: ValueKey<bool>(showActionButtons),
                    size: 32,
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else if (state is GetFinancialDataLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GetFinancialDataFailure) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar dados financeiros')),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
