import 'package:finc/screens/category/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:finc/screens/category/constants/category_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart'; // Importando repositório
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/category/modal%20category/created_category_modal.dart';

class CategoryOptionsModal extends StatefulWidget {
  final String userId;

  const CategoryOptionsModal({Key? key, required this.userId})
    : super(key: key);

  @override
  _CategoryOptionsModalState createState() => _CategoryOptionsModalState();
}

class _CategoryOptionsModalState extends State<CategoryOptionsModal> {
  Category? selectedCategory;
  String searchQuery = '';

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
      create:
          (_) => GetCategoriesBloc(
            context.read<ExpenseRepository>(), // Passando o ExpenseRepository
          )..add(GetCategories(currentUserId)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: FractionallySizedBox(
          heightFactor: 0.6, // Ajuste a altura conforme necessário
          child: ListView(
            children: [
              
              // Opção: Pesquisar Categorias
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 1,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Colors.white,            // Cor do cursor (linha piscando)
                    selectionColor: Colors.white24,       // Cor do fundo da seleção
                    selectionHandleColor: Color.fromARGB(255, 36, 112, 224),   // Cor dos pingos (handles)
                  ),
                ),
                  child: TextField(
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: 'Pesquisar categorias...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
              builder: (context, state) {
                if (state is GetCategoriesLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is GetCategoriesSuccess) {
                  // Filtra as categorias pelo nome e tipo 'expense', além de ordenar por data de criação.
                  final categories = state.categories
                  .where((category) =>
                      category.name.toLowerCase().contains(searchQuery) &&
                      category.type == 'expense')
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              final limitedCategories = categories.take(5).toList();

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
                    children: List.generate(limitedCategories.length, (index) {
                      final category = limitedCategories[index];
                      Color categoryColor = Color(category.color);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Transform.translate(
                                offset: const Offset(0, 0),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // ignore: unnecessary_null_comparison
                                    category.icon != null
                                        ? Image.asset(
                                            'assets/${category.icon}.png',
                                            width: 20,
                                            height: 20,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.category,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                  ],
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: selectedCategory == category
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.greenAccent, size: 15)
                                  : Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color.fromARGB(255, 238, 238, 238),
                                          width: 0.8,
                                        ),
                                      ),
                                    ),
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                                Navigator.pop(context, category);
                              },
                            ),
                            if (index != limitedCategories.length - 1)
                              Container(
                                height: 0.6,
                                color: Colors.white24,
                                margin: const EdgeInsets.only(top: 1),
                              ),
                          ],
                        ),
                      );
                    }),
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
                return const SizedBox.shrink();
              },
            ),


              const Divider(color: Colors.white24, height: 0.2,), // Mantive a espessura como estava
              // Opção: Gerenciar Categorias
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12), // Reduzindo o padding vertical
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
              const Divider(color: Colors.white24, height: 0.7,), // Nova linha com espessura reduzida
              // Opção: Criar Categoria
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text(
                  'Criar Categoria',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Fecha o modal atual
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF2C2C2C),
                    builder: (BuildContext modalContext) {
                      return BlocProvider(
                        create:
                            (_) => CreateCategoryBloc(
                              expenseRepository:
                                  context.read<ExpenseRepository>(),
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(17),
                          height: MediaQuery.of(modalContext).size.height * 0.60,

                          child: AddCategoryModal(
                            userId: FirebaseAuth.instance.currentUser!.uid, // <- Passando o userId aqui
                            onCategoryCreated: () {
                              final userId = FirebaseAuth.instance.currentUser?.uid;
                              if (userId != null) {
                                BlocProvider.of<GetCategoriesBloc>(
                                  modalContext,
                                ).add(GetCategories(userId));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const Divider(color: Colors.white24, height: 0.6,),
            ],
          ),
        ),
      ),
    );
  }
}
