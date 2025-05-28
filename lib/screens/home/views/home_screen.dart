import 'package:finc/routes/app_routes.dart';
import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/transactions/transaction_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late String userId;
  bool _hasFetchedData = false; // flag para evitar múltiplas chamadas

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedData) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        userId = args;
        // Dispara evento para buscar dados financeiros somente uma vez
        context.read<GetFinancialDataBloc>().add(GetFinancialData(userId));
        _hasFetchedData = true;
      } else {
        userId = '';
        // Se quiser, pode redirecionar para tela de login ou exibir erro
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetFinancialDataBloc, GetFinancialDataState>(
      builder: (context, state) {
        if (state is GetFinancialDataSuccess) {
          final pages = [
            MainScreen(state.expenses, state.income),
            const StatScreen(),
            TransactionScreen(transactions: state.expenses),
          ];

          return Scaffold(
            body: IndexedStack(
              index: index,
              children: pages,
            ),
            floatingActionButton: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              overlayOpacity: 0.3,
              spacing: 10,
              spaceBetweenChildren: 10,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.arrow_upward),
                  label: 'Receita',
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addIncome,
                      arguments: userId,
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.arrow_downward),
                  label: 'Despesa',
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addExpense,
                      arguments: userId,
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.compare_arrows),
                  label: 'Transferência',
                  backgroundColor: Colors.deepPurple,
                  onTap: () {
                    // Implementar lógica de transferência
                    print('Adicionar Transferência');
                  },
                ),
              ],
            ),
            bottomNavigationBar: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BottomNavigationBar(
                currentIndex: index,
                onTap: (value) {
                  setState(() {
                    index = value;
                  });
                },
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 3,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.graph_square_fill),
                    label: 'Stats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.list_bullet),
                    label: 'Transações',
                  ),
                ],
              ),
            ),
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
