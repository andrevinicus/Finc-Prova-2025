import 'dart:math';
import 'package:finc/screens/home/views/multi_selector_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_repository/expense_repository.dart'; // Assume que Expense, Income, Category, UserModel vêm daqui ou de outro lugar
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finc/screens/drawer/app_drawer.dart';



class MainScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Income> income;
  const MainScreen(this.expenses, this.income, {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime selectedMonth = DateTime.now();
  User? userGoogle;
  String? uid;
  Future<UserModel?>? futureUserModel;
  @override
  void initState() {
    super.initState();
    userGoogle = FirebaseAuth.instance.currentUser;
    uid = userGoogle?.uid;
    if (uid != null) {
      futureUserModel = FirebaseUserRepo().getUserById(uid!);
    }
  }
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR', // Define a localidade para formatação brasileira
      symbol: 'R\$',    // Define o símbolo da moeda
      decimalDigits: 2, // Garante duas casas decimais
    );
    // Filtra receitas para o mês e ano selecionados
    // A flag e.isIncome é redundante se widget.income é List<Income>
    final filteredMonthIncome = widget.income.where((incomeEntry) =>
        incomeEntry.date.month == selectedMonth.month &&
        incomeEntry.date.year == selectedMonth.year);
    // Filtra despesas para o mês e ano selecionados
    // A flag e.isExpense é redundante se widget.expenses é List<Expense>
    final filteredMonthExpenses = widget.expenses.where((expenseEntry) =>
        expenseEntry.date.month == selectedMonth.month &&
        expenseEntry.date.year == selectedMonth.year);

    final incomeTotal =
        filteredMonthIncome.fold<double>(0.0, (sum, e) => sum + e.amount);
    final expenseTotal =
        filteredMonthExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final balance = incomeTotal - expenseTotal;
    // --- INÍCIO DAS MODIFICAÇÕES PARA LISTA COMBINADA ---
    // Mapear despesas para DisplayListItem
    List<DisplayListItem> transactionsForListView = [];
    // Mapear despesas
    for (var expense in filteredMonthExpenses) {
      transactionsForListView.add(DisplayListItem(
        date: expense.date,
        amount: expense.amount,
        title: expense.description, // <--- AQUI: usa a descrição da despesa
        iconName: expense.category.icon,
        iconBackgroundColorValue: expense.category.color,
        isExpense: true,
      ));
    }
    // Mapear receitas
    for (var incomeEntry in filteredMonthIncome) {
      transactionsForListView.add(DisplayListItem(
        date: incomeEntry.date,
        amount: incomeEntry.amount,
        title: incomeEntry.description, // <--- AQUI: usa a descrição da receita
        iconName: incomeEntry.category.icon,   // Ajuste se Income usa outra estrutura para ícone/cor
        iconBackgroundColorValue: incomeEntry.category.color, // Ajuste se Income usa outra estrutura para ícone/cor
        isExpense: false,
      ));
    }
    // Ordenar todas as transações por data (mais recentes primeiro)
    transactionsForListView.sort((a, b) => b.date.compareTo(a.date));
    // --- FIM DAS MODIFICAÇÕES PARA LISTA COMBINADA ---
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(user: userGoogle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: userGoogle?.photoURL != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(userGoogle!.photoURL!),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.yellow[700],
                                ),
                                child: Icon(
                                  CupertinoIcons.person_fill,
                                  color: Colors.yellow[800],
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<UserModel?>(
                            future: futureUserModel,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(strokeWidth: 2); // Ajustado para ser menor
                              } else if (snapshot.hasData && snapshot.data != null) {
                                final user = snapshot.data!;
                                return Text(
                                  user.name.split(' ').take(2).join(' '),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                );
                              } else {
                                return const Text("Usuário");
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // --- SEU MONTHSELECTOR - SEM ALTERAÇÕES ---
              MonthSelector(
                onMonthChanged: (date) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      selectedMonth = date;
                    });
                  });
                },
              ),
              // --- SEU CARD DE BALANÇO - SEM ALTERAÇÕES ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      transform: const GradientRotation(pi / 4),
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.grey.shade300,
                        offset: const Offset(5, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Balanço Total',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          // MODIFICADO: Usa o currencyFormatter
                          currencyFormatter.format(balance),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white30,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.arrow_up,
                                      size: 12,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Receitas',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                       currencyFormatter.format(incomeTotal),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white30,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.arrow_down,
                                        size: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Despesas',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 95,
                                        child: Text(
                                          currencyFormatter.format(expenseTotal),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- CABEÇALHO DA LISTA DE TRANSAÇÕES - SEM ALTERAÇÕES ---
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transações',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Lógica para "View All" pode ser adicionada aqui
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              // --- LISTVIEW.BUILDER MODIFICADO ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 10), // Espaço para o FAB
                  itemCount: transactionsForListView.length, // USA A NOVA LISTA COMBINADA
                  itemBuilder: (context, int i) {
                    final transactionItem = transactionsForListView[i]; // PEGA O ITEM COMBINADO

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white, // Fundo branco para cada item
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [ // Sombra sutil opcional
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Color(transactionItem.iconBackgroundColorValue),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/${transactionItem.iconName}.png',
                                        scale: 2, // Ajuste conforme necessário
                                        color: Colors.white, // Cor do ícone em si
                                        errorBuilder: (context, error, stackTrace) { // Tratamento de erro se imagem não carregar
                                          return const Icon(Icons.error, color: Colors.white, size: 24);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox( // Para limitar a largura do título e evitar overflow
                                    width: MediaQuery.of(context).size.width * 0.35, // Ajuste a porcentagem conforme necessário
                                    child: Text(
                                      transactionItem.title,
                                      style: TextStyle(
                                        fontSize: 15, // Um pouco maior para melhor leitura
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis, // Evita que texto longo quebre o layout
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    // Adiciona sinal negativo para despesas se desejar, ou muda a cor.
                                    '${transactionItem.isExpense ? '-' : '+'} R\$ ${transactionItem.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600, // Mais destaque para o valor
                                      color: transactionItem.isExpense
                                          ? Colors.redAccent[700] // Cor para despesa
                                          : Colors.green[700],     // Cor para receita
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(transactionItem.date),
                                    style: TextStyle(
                                      fontSize: 13, // Um pouco menor
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}