import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/transactions/email_csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';


class TransactionScreen extends StatefulWidget {
  final String userId;

  const TransactionScreen({super.key, required this.userId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<dynamic> _filterTransactionsByYear(
    List<dynamic> transactions,
    int year,
  ) {
    return transactions.where((tx) => tx.date.year == year).toList();
  }


  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return BlocBuilder<GetFinancialDataBloc, GetFinancialDataState>(
      builder: (context, state) {
        if (state is GetFinancialDataLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GetFinancialDataFailure) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        if (state is GetFinancialDataSuccess) {
          final filteredExpenses = _filterTransactionsByYear(
            state.expenses,
            selectedYear,
          );
          final filteredIncomes = _filterTransactionsByYear(
            state.income,
            selectedYear,
          );
          final categoryMap = state.categoryMap;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Transações'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Despesas'), Tab(text: 'Receitas')],
              ),
              actions: [
                DropdownButton<int>(
                  value: selectedYear,
                  items:
                      List.generate(10, (i) => DateTime.now().year - i)
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(
                                '$year',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value;
                      });
                    }
                  },
                  underline: const SizedBox(),
                  iconEnabledColor: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed:
                      () => exportAndShareCsv(
                        filteredExpenses,
                        filteredIncomes,
                        categoryMap,
                        selectedYear, // <-- passe o ano atual selecionado
                      ),
                  tooltip: 'Exportar e compartilhar CSV',
                ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(
                  filteredExpenses,
                  categoryMap,
                  currencyFormatter,
                  isExpense: true,
                ),
                _buildTransactionList(
                  filteredIncomes,
                  categoryMap,
                  currencyFormatter,
                  isExpense: false,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTransactionList(
    List<dynamic> transactions,
    Map<String, Category> categoryMap,
    NumberFormat formatter, {
    required bool isExpense,
  }) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Nenhuma transação encontrada'));
    }

    final amountColor = isExpense ? Colors.redAccent[700] : Colors.green[700];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final category = categoryMap[tx.categoryId] ?? Category.empty;
        final amountPrefix = isExpense ? '-' : '+';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy').format(tx.date),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              trailing: Text(
                '$amountPrefix ${formatter.format(tx.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
