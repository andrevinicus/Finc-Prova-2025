import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_event.dart';
import 'package:expense_repository/expense_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) return;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await FirebaseUserRepo().saveGoogleUserIfNeeded(firebaseUser);
        context.read<AuthBloc>().add(AuthCheckRequested());
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login com Google: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // ajuste o valor como quiser
                child: Image.asset(
                  'assets/telainicial.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover, // ajuda a preencher a área com a imagem
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo ao Finc',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerencie suas finanças com facilidade',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );
                    context.read<AuthBloc>().add(AuthCheckRequested());
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const SizedBox(width: 210, child: Center(child: Text('Entrar'))),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () => _signInWithGoogle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/google.png',
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text('Entrar com Google'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text("Não tem uma conta? Crie aqui"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
