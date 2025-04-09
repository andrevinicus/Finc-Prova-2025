import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppDrawer extends StatefulWidget {
  final User? user;

  const AppDrawer({
    super.key,
    required this.user, 
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String nome = 'Usuário';
  String? email;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    carregarNomeUsuario();
  }

  Future<void> carregarNomeUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userModel = await FirebaseUserRepo().getUserById(user.uid);

      setState(() {
        nome = userModel?.name ?? user.displayName ?? 'Usuário';
        email = userModel?.email ?? user.email;
        photoUrl = userModel?.photoUrl ?? user.photoURL;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(nome),
            accountEmail: Text(email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final googleSignIn = GoogleSignIn();

              await googleSignIn.signOut();
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pop();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair do app'),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}