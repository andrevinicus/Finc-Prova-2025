import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:finc/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:finc/screens/home/views/main_screen.dart';
import 'package:finc/screens/stats/stats.dart';
import 'package:finc/screens/transactions/widgets/transaction_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
      builder: (context, state) {
        if (state is GetExpensesSuccess) {
          // Telas controladas pelo menu
          final pages = [
            MainScreen(state.expenses),
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
                    // ação para adicionar receita
                    print('Adicionar Receita');
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.arrow_downward),
                  label: 'Despesa',
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  onTap: () {
                    // ação para adicionar despesa
                    print('Adicionar Despesa');
                  },
                ),
              SpeedDialChild(
                child: const Icon(Icons.compare_arrows),
                label: 'Transferência',
                backgroundColor: Colors.deepPurple,
                onTap: () {
                  // ação para transferência
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
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
