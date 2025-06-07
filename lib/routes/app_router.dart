import 'package:finc/routes/app_routes.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:finc/screens/add_expense/views/add_expense_screen.dart';
import 'package:finc/screens/add_income/blocs/create_expense_bloc/create_income_bloc.dart';
import 'package:finc/screens/add_income/views/add_income_screen.dart';
import 'package:finc/screens/login/register/login_screen.dart';
import 'package:finc/screens/login/register/register_screen.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/category/modal%20category/option_category_expense.dart';
import 'package:finc/screens/category/modal%20category/option_category_income.dart';
import 'package:finc/screens/create_banks/add_banks.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_banks_blco.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_event.dart';
import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/home/views/home_screen.dart'; 
import 'package:finc/screens/transactions/transaction_screen.dart';
import 'package:finc/screens/transfer/bloc/transfer_bloc.dart';
import 'package:finc/screens/transfer/transfer_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        builder: (context) => BlocProvider(
          create: (_) => GetFinancialDataBloc(
            expenseRepository: FirebaseExpenseRepo(),
            incomeRepository: FirebaseIncomeRepo(),
          )..add(GetFinancialData(userId)),
          child: HomeScreen(),
        ),
        settings: RouteSettings(arguments: userId),
      );

      case AppRoutes.addExpense:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories(userId)),
              ),
              BlocProvider(
                create: (_) => CreateExpenseBloc(FirebaseExpenseRepo()),
              ),
              BlocProvider(
                create: (_) => GetBankBloc(BankRepository())..add(GetLoadBanks(userId)),
              ),
            ],
            child: AddExpenseScreen(userId: userId),
          ),
        );
        case AppRoutes.transfer:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<TransferBloc>(
            create: (context) => TransferBloc(
              expenseRepository: context.read<ExpenseRepository>(),
            ),
            child: const TransferScreen(),
          ),
        );
    case AppRoutes.addIncome:
      final userId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories(userId)),
            ),
            BlocProvider(
              create: (_) => CreateIncomeBloc(FirebaseIncomeRepo()),
            ),
            BlocProvider(
              create: (_) => GetBankBloc(BankRepository())..add(GetLoadBanks(userId)),
            ),
          ],
          child: AddIncomeScreen(userId: userId),
        ),
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
        builder: (context) {
          return BlocProvider<AddBankBloc>(
            create: (_) => AddBankBloc(bankRepository: BankRepository()),
            child: AddBanksScreen(userId: userId),
          );
        },
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
