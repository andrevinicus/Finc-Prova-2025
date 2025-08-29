import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Repositórios
import 'package:expense_repository/expense_repository.dart';

// Blocs
import 'package:finc/auth/auth_bloc.dart';
import 'package:finc/auth/auth_event.dart';
import 'package:finc/auth/auth_state.dart';
import 'package:finc/screens/category/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_event.dart';
import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';

import 'package:finc/screens/home/views/home_screen.dart';
import 'package:finc/screens/login/register/login_screen.dart';

import 'routes/app_router.dart';
import 'routes/app_routes.dart';

void main() {
  final expenseRepository = FirebaseExpenseRepo();
  final incomeRepository = FirebaseIncomeRepo();
  final bankRepository = BankRepository();
  final categoryRepository = FirebaseCategoryRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<IncomeRepository>.value(value: incomeRepository),
        RepositoryProvider<BankRepository>.value(value: bankRepository),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested()),
        child: const MyAppView(),
      ),
    ),
  );
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ],
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFF5F5F5),
          onSurface: Color.fromARGB(255, 49, 48, 48),
          primary: Color.fromARGB(255, 37, 43, 51),
          secondary: Color.fromARGB(255, 36, 59, 46),
          tertiary: Color.fromARGB(255, 138, 107, 73),
          outline: Color(0xFFB0B0B0),
          primaryContainer: Color.fromARGB(255, 36, 112, 224),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final userId = state.user.uid;

            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => GetExpensesBloc(context.read<ExpenseRepository>())
                    ..add(GetExpenses(userId)),
                ),
                BlocProvider(
                  create: (context) => GetCategoriesBloc(categoryRepository: context.read<CategoryRepository>())
                    ..add(GetCategories(userId)),
                ),
                BlocProvider(
                  create: (context) => CreateCategoryBloc(categoryRepository: context.read<CategoryRepository>()),
                ),
                BlocProvider(
                  create: (context) => GetBankBloc(context.read<BankRepository>())
                    ..add(GetLoadBanks(userId)),
                ),
                BlocProvider(
                  create: (context) => GetFinancialDataBloc(
                    expenseRepository: context.read<ExpenseRepository>(),
                    incomeRepository: context.read<IncomeRepository>(),
                    categoryRepository: context.read<CategoryRepository>(),
                  )..add(GetFinancialData(userId)),
                ),
              ],
              child: const HomeScreen(),
            );
          } else if (state is Unauthenticated) {
            return const LoginScreen();
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
