import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/login/register/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppDrawer extends StatefulWidget {
  final User? user;

  const AppDrawer({super.key, required this.user});

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
          nome = userModel.name;
          email = userModel.email;
          photoUrl = userModel.photoUrl ?? photoUrl;
        });
      }
    } catch (e) {
      if (mounted) print("Erro ao carregar dados do usuário: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // Altura do BottomNavigationBar (padrão Flutter)
    final bottomNavBarHeight = kBottomNavigationBarHeight;

    // Altura máxima disponível para o Drawer
    final drawerMaxHeight = screenHeight - bottomNavBarHeight;

    return Drawer(
      width: screenWidth * 0.58,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: drawerMaxHeight,
          ),
          child: Column(
            children: [
              // Header
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                accountName: Text(
                  nome,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                accountEmail:
                    Text(email ?? '', style: const TextStyle(color: Colors.white70)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null
                      ? Icon(Icons.person,
                          size: 40,
                          color: theme.colorScheme.onSurface.withOpacity(0.6))
                      : null,
                ),
              ),

              // Menu rolável
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: const Text('Transações'),
                        onTap: () {
                          Navigator.of(context).pop();
                          final userId = widget.user?.uid ?? '';
                          if (userId.isNotEmpty) {
                            Navigator.of(context).pushNamed(
                              '/transaction',
                              arguments: {'userId': userId},
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Configurações'),
                        onTap: () {
                          Navigator.of(context).pop();
                          print('Ir para Configurações');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Rodapé fixo
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.redAccent)),
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
                    onTap: () => SystemNavigator.pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
