import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/auth/auth_bloc.dart';
import 'package:finc/auth/auth_event.dart';
import 'package:finc/app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseRepository = FirebaseExpenseRepo();
    final bankRepository = BankRepository();
    final incomeRepository = FirebaseIncomeRepo(); 
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<IncomeRepository>.value(value: incomeRepository),
        RepositoryProvider<BankRepository>.value(value: bankRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested()),
        child: const MyAppView(),
      ),
    );
  }
}
