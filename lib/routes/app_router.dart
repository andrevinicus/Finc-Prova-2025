import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/home/views/home_screen.dart';
import 'package:finc/screens/login/register/login_screen.dart';
import 'package:finc/screens/login/register/register_screen.dart';
import 'package:finc/screens/add_expense/views/add_expense_screen.dart';
import 'package:finc/screens/add_income/views/add_income_screen.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_event.dart';
import 'package:finc/screens/create_banks/add_banks.dart';
import 'package:finc/screens/transactions/transaction_screen.dart';
import 'package:finc/screens/transfer/transfer_screen.dart';
import 'package:finc/screens/AIChatScreen/AIChatScreen.dart';
import 'package:finc/screens/transfer/bloc/transfer_bloc.dart';
import 'package:finc/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:finc/screens/add_income/blocs/create_expense_bloc/create_income_bloc.dart';
import 'package:finc/screens/category/modal%20category/option_category_expense.dart';
import 'package:finc/screens/category/modal%20category/option_category_income.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_banks_blco.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

        case AppRoutes.home:
          return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => GetFinancialDataBloc(
                    expenseRepository: RepositoryProvider.of<ExpenseRepository>(context),
                    incomeRepository: RepositoryProvider.of<IncomeRepository>(context),
                    categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
                  ),
                ),
              ],
              child: const HomeScreen(), // ❌ não precisa mais passar userId
            ),
          );

      case AppRoutes.addExpense:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => GetCategoriesBloc(
                  categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
                )..add(GetCategories(userId)),
              ),
              BlocProvider(
                create: (context) => CreateExpenseBloc(
                  RepositoryProvider.of<ExpenseRepository>(context),
                ),
              ),
              BlocProvider(
                create: (context) => GetBankBloc(
                  RepositoryProvider.of<BankRepository>(context),
                )..add(GetLoadBanks(userId)),
              ),
            ],
            child: AddExpenseScreen(userId: userId),
          ),
        );

      case AppRoutes.addIncome:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => GetCategoriesBloc(
                  categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
                )..add(GetCategories(userId)),
              ),
              BlocProvider(
                create: (context) => CreateIncomeBloc(
                  RepositoryProvider.of<IncomeRepository>(context),
                ),
              ),
              BlocProvider(
                create: (context) => GetBankBloc(
                  RepositoryProvider.of<BankRepository>(context),
                )..add(GetLoadBanks(userId)),
              ),
            ],
            child: AddIncomeScreen(userId: userId),
          ),
        );

      case AppRoutes.transfer:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => TransferBloc(
            expenseRepository: RepositoryProvider.of<ExpenseRepository>(context), // ✅ named parameter
          ),
          child: const TransferScreen(),
        ),
      );

      case AppRoutes.transaction:
        final args = settings.arguments as Map<String, dynamic>;
        final userId = args['userId'] as String; // pegando apenas o userId
        return MaterialPageRoute(
          builder: (_) => TransactionScreen(
            userId: userId, // ✅ agora bate com o construtor
          ),
        );

      case AppRoutes.aiChat:
        final args = settings.arguments as Map<String, String>;
        final userId = args["userId"]!;
        final userName = args["userName"]!;
        return MaterialPageRoute(
          builder: (_) => AIChatScreen(userId: userId, userName: userName),
        );

      case AppRoutes.categoryOptionsExpense:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CategoryOptionsModalExpense(userId: userId),
        );

      case AppRoutes.categoryOptionsIncome:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CategoryOptionsModalIncome(userId: userId),
        );

        case AppRoutes.addBanks:
          final userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => AddBankBloc(
                bankRepository: RepositoryProvider.of<BankRepository>(context), // ✅ named parameter
              ),
              child: AddBanksScreen(userId: userId),
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
