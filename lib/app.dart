import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_event.dart';
import 'package:finc/app_view.dart'; // ou MyAppView, dependendo de onde você definiu

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested()),
      child: const MyAppView(),
    );
  }
}
