import 'package:expense_repository/expense_repository.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_state.dart';
import 'package:finc/screens/auth/register_screen.dart';
import 'package:finc/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home/views/home_screen.dart';
import 'screens/auth/login_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: const Color.fromARGB(255, 0, 0, 0),
          secondary: const Color.fromARGB(255, 110, 110, 110),
          tertiary: const Color.fromARGB(255, 245, 244, 244),
          outline: Colors.grey,
        ),
      ),
      // Rotas nomeadas para evitar erro ao navegar por string
      routes: {
        '/home': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return BlocProvider(
            create: (context) => GetExpensesBloc(FirebaseExpenseRepo())..add(GetExpenses(userId)),
            child: const HomeScreen(),
          );
        },
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return BlocProvider(
              create: (context) =>
                  GetExpensesBloc(FirebaseExpenseRepo())..add(GetExpenses(state.user.uid)),
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
