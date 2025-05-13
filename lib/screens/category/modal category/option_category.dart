import 'package:finc/screens/category/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart'; // Importando repositório
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/category/modal%20category/created_category_modal.dart';

class CategoryOptionsModal extends StatelessWidget {
  final String userId;

  const CategoryOptionsModal({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verifica se o usuário está autenticado
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      // Se o usuário não estiver autenticado, exibe uma mensagem de erro
      return Center(
        child: Text(
          'Usuário não autenticado',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    // Envolva o widget com BlocProvider aqui
    return BlocProvider<GetCategoriesBloc>(
      create: (_) => GetCategoriesBloc(
        context.read<ExpenseRepository>(), // Passando o ExpenseRepository
      )..add(GetCategories(currentUserId)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: FractionallySizedBox(
          heightFactor: 0.6, // Ajuste a altura conforme necessário
          child: ListView(
            children: [
              const Divider(color: Colors.white24),

              // Opção: Pesquisar Categorias
              ListTile(
                leading: const Icon(Icons.search, color: Colors.white),
                title: const Text(
                  'Pesquisar Categorias',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Fechar o modal
                  // Aqui você pode implementar a busca, se necessário
                },
              ),

              // 🔽 Lista de últimas 3 categorias criadas
              BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                builder: (context, state) {
                  if (state is GetCategoriesLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is GetCategoriesSuccess) {
                    final categories = state.categories.take(3).toList();
                    if (categories.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nenhuma categoria encontrada.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.map((category) {
                        return ListTile(
                          // ignore: unnecessary_null_comparison
                          leading: category.icon != null
                              ? Image.asset(
                                  'assets/${category.icon}.png', // Ajuste o caminho conforme necessário
                                  width: 30,
                                  height: 30,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.category,
                                  color: Colors.white,
                                ),
                          title: Text(
                            category.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Tipo: ${category.type}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          onTap: () {
                            Navigator.pop(context, category);
                          },
                        );
                      }).toList(),
                    );
                  } else if (state is GetCategoriesFailure) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Erro ao carregar categorias',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  return const SizedBox.shrink(); // Estado inicial
                },
              ),

              const Divider(color: Colors.white24),

              // Opção: Gerenciar Categorias
              ListTile(
                leading: const Icon(Icons.manage_accounts, color: Colors.white),
                title: const Text(
                  'Gerenciar Categorias',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Fechar o modal
                  // Implementar lógica de gerenciamento de categorias
                },
              ),

              const Divider(color: Colors.white24),

              // Opção: Criar Categoria
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Criar Categoria', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context); // Fecha o modal atual
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF2C2C2C),
                    builder: (BuildContext modalContext) {
                      return BlocProvider(
                        create: (_) => CreateCategoryBloc(
                          expenseRepository: context.read<ExpenseRepository>(),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: MediaQuery.of(modalContext).size.height * 0.65, // Dinamicamente ajustando o tamanho
                          child: AddCategoryModal(
                            onCategoryCreated: () {
                              // Atualiza as categorias após criar uma nova categoria
                              final userId = FirebaseAuth.instance.currentUser?.uid;
                              if (userId != null) {
                                BlocProvider.of<GetCategoriesBloc>(modalContext).add(GetCategories(userId));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const Divider(color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
