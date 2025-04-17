import 'package:finc/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:finc/screens/add_expense/views/add_expense_screen.dart';
import 'package:finc/screens/transactions/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:finc/routes/app_routes.dart';
import 'package:finc/screens/auth/login_screen.dart';
import 'package:finc/screens/auth/register_screen.dart';
import 'package:finc/screens/home/views/home_screen.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.transaction:
        final transactions = settings.arguments as List<Expense>;
        return MaterialPageRoute(
          builder: (_) => TransactionScreen(transactions: transactions),
        );

      case AppRoutes.home:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => GetExpensesBloc(FirebaseExpenseRepo())..add(GetExpenses(userId)),
              ),
              BlocProvider(
                create: (_) => GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories(userId)),
              ),
            ],
            child: const HomeScreen(),
          ),
        );
      case AppRoutes.addExpense:
      final userId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories(userId)),
            ),
            BlocProvider(
              create: (_) => CreateExpenseBloc(FirebaseExpenseRepo()),
            ),
          ],
          child: AddExpenseScreen(userId: userId),
        ),
      );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}