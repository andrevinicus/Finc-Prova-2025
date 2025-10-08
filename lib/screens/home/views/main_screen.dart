import 'package:finc/Notification/bloc_notifica/notification_bloc.dart';
import 'package:finc/Notification/bloc_notifica/notification_event.dart';
import 'package:finc/Notification/notification.dart';
import 'package:finc/screens/home/views/main_screen/balance_cards.dart';
import 'package:finc/screens/home/views/main_screen/transaction_list.dart';
import 'package:finc/screens/home/views/main_screen/user_header.dart';
import 'package:finc/multi_selector_date/multi_selector_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:finc/screens/drawer/app_drawer.dart';

class MainScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Income> income;
  final Map<String, Category> categoryMap; // Adicionado

  const MainScreen({
    super.key,
    required this.expenses,
    required this.income,
    required this.categoryMap, // Adicionado
  });

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
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final filteredMonthIncome = widget.income.where(
      (incomeEntry) =>
          incomeEntry.date.month == selectedMonth.month &&
          incomeEntry.date.year == selectedMonth.year,
    );

    final filteredMonthExpenses = widget.expenses.where(
      (expenseEntry) =>
          expenseEntry.date.month == selectedMonth.month &&
          expenseEntry.date.year == selectedMonth.year,
    );

    final incomeTotal = filteredMonthIncome.fold<double>(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final expenseTotal = filteredMonthExpenses.fold<double>(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final balance = incomeTotal - expenseTotal;

    final transactionsForListView = [
      // Despesas
      ...filteredMonthExpenses.map((expense) {
        final expenseCatId = expense.categoryId.toString().trim();
        final category = widget.categoryMap[expenseCatId] ?? Category.empty;

        return DisplayListItem(
          date: expense.date,
          amount: expense.amount,
          title: expense.description,
          iconName: category.icon,
          iconBackgroundColorValue: category.color,
          isExpense: true,
        );
      }),
      // Receitas
      ...filteredMonthIncome.map((incomeEntry) {
        final incomeCatId = incomeEntry.categoryId.toString().trim();
        final category = widget.categoryMap[incomeCatId] ?? Category.empty;

        return DisplayListItem(
          date: incomeEntry.date,
          amount: incomeEntry.amount,
          title: incomeEntry.description,
          iconName: category.icon,
          iconBackgroundColorValue: category.color,
          isExpense: false,
        );
      }),
    ];

    transactionsForListView.sort((a, b) => b.date.compareTo(a.date));

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
                  Expanded(
                    child: UserHeader(
                      userGoogle: userGoogle,
                      futureUserModel: futureUserModel,
                      scaffoldKey: _scaffoldKey,
                    ),
                  ),
                  BlocProvider(
                    create: (context) {
                      final repository = NotificationRepository();
                      final localNotifications =
                          FlutterLocalNotificationsPlugin();
                      final String idApp =
                          uid ?? ''; // 🔹 aqui você passa o userId
                      return NotificationBloc(
                        repository: repository,
                        localNotifications: localNotifications,
                        idApp: idApp, // obrigatório agora
                      )..add(
                        LoadNotifications(idApp),
                      ); // já dispara o carregamento
                    },
                    child: Builder(
                      builder: (context) {
                        final bloc = context.read<NotificationBloc>();
                        return NotificationBell(bloc: bloc);
                      },
                    ),
                  ),
                ],
              ),

              MonthSelector(
                onMonthChanged: (date) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      selectedMonth = date;
                    });
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: BalanceCard(
                  balance: balance,
                  incomeTotal: incomeTotal,
                  expenseTotal: expenseTotal,
                  currencyFormatter: currencyFormatter,
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transações',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: TransactionList(transactions: transactionsForListView),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
