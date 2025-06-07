import 'package:expense_repository/expense_repository.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importe o IncomeRepository e sua implementação


void main() {
  final expenseRepository = FirebaseExpenseRepo();
  final incomeRepository = FirebaseIncomeRepo();  // Novo repositório para receitas
  final bankRepository = BankRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<IncomeRepository>.value(value: incomeRepository),  // registro IncomeRepository
        RepositoryProvider<BankRepository>.value(value: bankRepository),
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
  return Builder(
    builder: (context) {
      final expenseRepository = context.read<ExpenseRepository>();
      final incomeRepository = context.read<IncomeRepository>();
      final bankRepository = context.read<BankRepository>();

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
                    create: (_) => GetExpensesBloc(expenseRepository)..add(GetExpenses(userId)),
                  ),
                  BlocProvider(
                    create: (_) => GetCategoriesBloc(expenseRepository)..add(GetCategories(userId)),
                  ),
                  BlocProvider(
                    create: (_) => CreateCategoryBloc(expenseRepository: expenseRepository),
                  ),
                  BlocProvider(
                    create: (_) => GetBankBloc(bankRepository)..add(GetLoadBanks(userId)),
                  ),
                  BlocProvider(
                    create: (_) => GetFinancialDataBloc(
                      expenseRepository: expenseRepository,
                      incomeRepository: incomeRepository,
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
    },
  );
}

}
