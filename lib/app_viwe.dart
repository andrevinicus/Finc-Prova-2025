import 'package:finc/screens/home/viwes/home_screen.dart';
import 'package:flutter/material.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade50,      
          onBackground: Colors.black87,        
          primary: const Color.fromARGB(255, 33, 36, 39),     
          secondary: const Color.fromARGB(255, 83, 90, 95),   
          tertiary: const Color(0xFFB6A29A),    
          error: const Color(0xFFC1351D),       
          outline: Colors.grey.shade500,
        )
      ),
      home: const HomeScreen(),
    );
  }
}