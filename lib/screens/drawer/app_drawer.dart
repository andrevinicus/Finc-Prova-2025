import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/auth/login_screen.dart'; // Certifique-se que o caminho está correto
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
    if (widget.user != null) {
      nome = widget.user!.displayName ?? 'Usuário';
      email = widget.user!.email;
      photoUrl = widget.user!.photoURL;
      _loadCustomUserData();
    }
  }

  Future<void> _loadCustomUserData() async {
    if (widget.user == null) return;
    try {
      final userModel = await FirebaseUserRepo().getUserById(widget.user!.uid);
      if (mounted && userModel != null) {
        setState(() {
          nome = userModel.name ?? nome;
          email = userModel.email ?? email;
          photoUrl = userModel.photoUrl ?? photoUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Erro ao carregar dados personalizados do usuário no AppDrawer: $e");
      }
    }
  }

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final screenWidth = MediaQuery.of(context).size.width; // Para calcular a largura do drawer

  return Drawer(
    // AJUSTE 1: Remover bordas arredondadas (garantir cantos retos)
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),

    // AJUSTE 2: Diminuir o tamanho de abertura (largura)
    // Experimente valores como 70% da tela (screenWidth * 0.7) ou um valor fixo.
    // O padrão é aproximadamente 304dp.
    width: screenWidth * 0.75, // Exemplo: 75% da largura da tela. Ajuste conforme necessário.
    // Ou um valor fixo: width: 280,

    child: Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
          ),
          accountName: Text(
            nome,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          accountEmail: Text(
            email ?? '',
            style: const TextStyle(color: Colors.white70),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  )
                : null,
          ),
          // Opcional: Para um header mais compacto, descomente a linha abaixo
          // margin: EdgeInsets.zero,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Configurações'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implementar navegação para tela de configurações
                  // Navigator.of(context).pushNamed(AppRoutes.settings);
                  print('Ir para Configurações');
                },
              ),
              // Adicione mais itens de menu aqui, se desejar
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          onTap: () async {
            final googleSignIn = GoogleSignIn();
            try {
              await googleSignIn.signOut();
              await FirebaseAuth.instance.signOut();
            } catch (e) {
              print("Erro durante o logout: $e");
            }

            if (!mounted) return;
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
        const SizedBox(height: 8),
      ],
    ),
  );
}
}