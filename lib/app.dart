import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_event.dart';
import 'package:finc/app_view.dart'; // onde está o MyAppView

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseRepository = FirebaseExpenseRepo();

    return RepositoryProvider<ExpenseRepository>.value(
      value: expenseRepository,
      child: BlocProvider(
        create: (_) => AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested()),
        child: MyAppView(expenseRepository: expenseRepository),
      ),
    );
  }
}
