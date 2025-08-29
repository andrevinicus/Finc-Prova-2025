import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  final List<dynamic> transactions; // Pode ser Expense ou Income
  final Map<String, Category> categoryMap;

  const TransactionScreen({
    super.key,
    required this.transactions,
    required this.categoryMap,
  });

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
    final expenses = widget.transactions.where((t) => (t.type == 'despesa')).toList();
    final incomes = widget.transactions.where((t) => (t.type == 'income')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transações"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorWeight: 3,
          labelColor: Theme.of(context).colorScheme.onBackground,
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

  Widget _buildTransactionList(BuildContext context, List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/empty.png', height: 150),
            const SizedBox(height: 20),
            Text(
              'Nenhuma transação encontrada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Clique no botão "+" para adicionar',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isExpense = tx.type == 'despesa';
        final amountPrefix = isExpense ? "- " : "+ ";
        final amountColor = isExpense
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.secondary;

        // Buscar categoria pelo categoryId
        final category = widget.categoryMap[tx.categoryId] ?? Category.empty;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy').format(tx.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              '$amountPrefix\$ ${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: amountColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
