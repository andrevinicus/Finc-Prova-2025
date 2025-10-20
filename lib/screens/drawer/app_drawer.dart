import 'package:expense_repository/expense_repository.dart';
import 'package:finc/perfils/perfil_screen.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/login/register/login_screen.dart';
import 'package:finc/screens/transactions/transaction_screen.dart';
import 'package:finc/screens/whatsapp_flow/wpp_pendencia.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_bloc.dart';
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

  /// Apenas visual: sinal vermelho se houver pendências para lançar
  bool _hasPendenciasParaLancar() {
    // Aqui você pode substituir por dados reais
    return true; // sempre mostra o sinal como exemplo
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    final bottomNavBarHeight = kBottomNavigationBarHeight;
    final drawerMaxHeight = screenHeight - bottomNavBarHeight;

    return Drawer(
      width: screenWidth * 0.58,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: drawerMaxHeight),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: theme.colorScheme.surface,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl!) : null,
                    child:
                        photoUrl == null
                            ? Icon(
                              Icons.person,
                              size: 40,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            )
                            : null,
                  ),
                ),

                // Menu rolável
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Perfil'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PerfilScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: const Text('Transações'),
                          onTap: () {
                            Navigator.of(context).pop();
                            final userId = widget.user?.uid ?? '';
                            if (userId.isNotEmpty) {
                              final financialBloc =
                                  context.read<GetFinancialDataBloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => BlocProvider.value(
                                        value: financialBloc,
                                        child: TransactionScreen(
                                          userId: userId,
                                        ),
                                      ),
                                ),
                              );
                            }
                          },
                        ),

                        // Pendências Financeiras com sinal
                        ListTile(
                          leading: const Icon(Icons.pending_actions),
                          title: const Text('Pendências Financeiras'),
                          trailing:
                              _hasPendenciasParaLancar()
                                  ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                  : null,
                          onTap: () {
                            Navigator.of(context).pop();
                            final userId = widget.user?.uid ?? '';
                            if (userId.isNotEmpty) {
                              // Pega os blocos já existentes
                              final lancamentoBloc =
                                  context.read<AnaliseLancamentoBloc>();
                              final categoriesBloc =
                                  context.read<GetCategoriesBloc>();

                              // Passa ambos os blocos via MultiBlocProvider
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(
                                            value: lancamentoBloc,
                                          ),
                                          BlocProvider.value(
                                            value: categoriesBloc,
                                          ),
                                        ],
                                        child: PendenciasScreen(userId: userId),
                                      ),
                                ),
                              );
                            }
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
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
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
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
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
      ),
    );
  }
}
