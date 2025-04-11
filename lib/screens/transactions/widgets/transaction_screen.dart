import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  final List<Expense> transactions;

  const TransactionScreen({super.key, required this.transactions});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final expenses = widget.transactions.where((t) => t.isExpense).toList();
    final incomes = widget.transactions.where((t) => !t.isExpense).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transações"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Despesas"),
            Tab(text: "Receitas"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(context, expenses),
          _buildTransactionList(context, incomes),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, List<Expense> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/empty.png', height: 150), // opcional
            const SizedBox(height: 20),
            const Text(
              'Ops! Você não possui transações registradas.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Para criar um novo item, clique no botão (+)'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
            title: Text(tx.category.name),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
            trailing: Text(
              '${tx.isExpense ? '-' : '+'} R\$ ${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: tx.isExpense
                    ? Theme.of(context).colorScheme.tertiary // vermelho
                    : Theme.of(context).colorScheme.secondary, // verde
              ),
            ),
          ),
        );
      },
    );
  }
}
