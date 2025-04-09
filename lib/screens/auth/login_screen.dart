import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/blocs/auth/auth_bloc.dart';
import 'package:finc/blocs/auth/auth_event.dart';
import 'package:expense_repository/expense_repository.dart'; // Ajuste conforme o caminho do seu repo

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) {
        // Usuário cancelou o login
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Salva o usuário no Firestore se ainda não existir
        await FirebaseUserRepo().saveGoogleUserIfNeeded(firebaseUser);

        // Redireciona para a home
        Navigator.pushReplacementNamed(context, '/home');

        // Dispara evento para o AuthBloc
        context.read<AuthBloc>().add(AuthCheckRequested());
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  );

                  // Redireciona após login bem-sucedido
                  Navigator.pushReplacementNamed(context, '/home');

                  context.read<AuthBloc>().add(AuthCheckRequested());
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar com Google'),
              onPressed: () => _signInWithGoogle(context),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}
