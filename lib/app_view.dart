import 'package:expense_repository/expense_repository.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_state.dart';
import 'package:finc/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home/views/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'routes/app_router.dart'; // Importante
import 'routes/app_routes.dart'; // Contém as rotas nomeadas

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

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
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute, // 👈 ESSENCIAL
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => GetExpensesBloc(FirebaseExpenseRepo())
                    ..add(GetExpenses(state.user.uid)),
                ),
                BlocProvider(
                  create: (_) => GetCategoriesBloc(FirebaseExpenseRepo())
                    ..add(GetCategories(state.user.uid)),
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