import 'package:finc/routes/app_routes.dart';
import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/transactions/transaction_screen.dart';
import 'package:finc/screens/home/views/main_screen.dart';
import 'package:finc/screens/stats/stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int index = 0;
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
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        userId = args;
        context.read<GetFinancialDataBloc>().add(GetFinancialData(userId));
        _hasFetchedData = true;
      } else {
        userId = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<GetFinancialDataBloc, GetFinancialDataState>(
      builder: (context, state) {
        if (state is GetFinancialDataSuccess) {
          final pages = [
            MainScreen(state.expenses, state.income),
            StatScreen(userId: userId,),
            TransactionScreen(transactions: state.expenses),
          ];

          return Scaffold(
            body: Stack(
              children: [
                IndexedStack(
                  index: index,
                  children: pages,
                ),

                // BottomNavigationBar fixado na base, por baixo do fundo escurecido
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: index,
                    onTap: (value) {
                      setState(() {
                        index = value;
                      });
                    },
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    elevation: 3,
                    backgroundColor: Colors.white,
                    selectedItemColor: const Color.fromARGB(195, 22, 22, 22),
                    unselectedItemColor: Colors.grey,
                    items:  [
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.home),
                        activeIcon: Icon(CupertinoIcons.house_fill, size: 26),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Transform.translate(
                          offset: Offset(-22, 0), // move para a esquerda
                          child: Icon(CupertinoIcons.graph_square),
                        ),
                        activeIcon: Transform.translate(
                          offset: Offset(-22, 0), // move para a esquerda
                          child: Icon(CupertinoIcons.graph_square_fill, size: 26),
                        ),
                        label: 'Stats',
                      ),
                      BottomNavigationBarItem(
                        icon: Transform.translate(
                          offset: Offset(22, 0), // move para a esquerda
                          child: Icon(CupertinoIcons.list_bullet),
                        ),
                        activeIcon: Transform.translate(
                          offset: Offset(22, 0), // move para a esquerda
                          child: Icon(CupertinoIcons.list_bullet_indent, size: 26),
                        ),
                        label: 'Transações',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_outlined),
                        activeIcon: Icon(Icons.settings, size: 26),
                        label: 'Configurações',
                      ),
                    ],
                  ),
                ),
              ),
                // Fundo escurecido cobre o BottomNavigationBar quando menu aberto
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
                        opacity: showActionButtons ? 0.6 : 0,
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ),

                // Botões animados ficam por cima do fundo
                // Botão Transferência (acima)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: showActionButtons ? 90 : 40,
                  left: screenWidth / 2 - 50,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showActionButtons ? 1 : 0,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'transferBtn',
                          backgroundColor: Colors.deepPurple,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.transfer,
                              arguments: userId,
                            );
                            setState(() {
                              showActionButtons = false;
                              _controller.reverse();
                            });
                          },
                          child: const Icon(Icons.compare_arrows),
                        ),
                        const SizedBox(height: 6),
                        const Text("Transferência", style: TextStyle(fontSize: 15, color: Colors.white), ),
                      ],
                    ),
                  ),
                ),

                // Botão Despesa (diagonal esquerda)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: 60,
                  left: showActionButtons ? screenWidth / 2 - 125 : screenWidth / 2 - 18,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showActionButtons ? 1 : 0,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'expenseBtn',
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.addExpense,
                              arguments: userId,
                            );
                            setState(() {
                              showActionButtons = false;
                              _controller.reverse();
                            });
                          },
                          child: const Icon(Icons.arrow_downward),
                        ),
                        const SizedBox(height: 6),
                        const Text("Despesa", style: TextStyle(fontSize: 15, color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                // Botão Receita (diagonal direita)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: 60,
                  left: showActionButtons ? screenWidth / 2 + 70 : screenWidth / 2 - 18,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showActionButtons ? 1 : 0,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'incomeBtn',
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.addIncome,
                              arguments: userId,
                            );
                            setState(() {
                              showActionButtons = false;
                              _controller.reverse();
                            });
                          },
                          child: const Icon(Icons.arrow_upward),
                        ),
                        const SizedBox(height: 6),
                        const Text("Receita", style: TextStyle(fontSize: 15, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                setState(() {
                  showActionButtons = !showActionButtons;
                  if (showActionButtons) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                });
              },
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_controller), 
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    showActionButtons ? Icons.close : Icons.add,
                    key: ValueKey<bool>(showActionButtons),
                    size: 32,
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        }
        else if (state is GetFinancialDataLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        else if (state is GetFinancialDataFailure) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar dados financeiros')),
          );
        }
        else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
