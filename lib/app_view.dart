import 'package:expense_repository/expense_repository.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_state.dart';
import 'package:finc/screens/category/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home/views/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';


void main() {
  final expenseRepository = FirebaseExpenseRepo();

  runApp(
    RepositoryProvider<ExpenseRepository>.value(
      value: expenseRepository,
      child: MyAppView(expenseRepository: expenseRepository),
    ),
  );
}

class MyAppView extends StatelessWidget {
  final ExpenseRepository expenseRepository;

  const MyAppView({super.key, required this.expenseRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: const Color(0xFFF5F5F5),
          onSurface: const Color.fromARGB(255, 49, 48, 48),
          primary: const Color.fromARGB(255, 37, 43, 51),
          secondary: const Color.fromARGB(255, 36, 59, 46),
          tertiary: const Color.fromARGB(255, 138, 107, 73),
          outline: const Color(0xFFB0B0B0),
          primaryContainer: const Color.fromARGB(255, 36, 112, 224),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        if (state is Authenticated) {
          // Inicialização dos blocos
          final getExpensesBloc = GetExpensesBloc(expenseRepository)..add(GetExpenses(state.user.uid));
          final getCategoriesBloc = GetCategoriesBloc(expenseRepository)..add(GetCategories(state.user.uid));
          final createCategoryBloc = CreateCategoryBloc(expenseRepository: expenseRepository);

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getExpensesBloc),
              BlocProvider.value(value: getCategoriesBloc),
              BlocProvider.value(value: createCategoryBloc),
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
      }),
    );
  }
}
