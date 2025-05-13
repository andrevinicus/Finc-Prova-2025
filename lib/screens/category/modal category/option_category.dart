import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:flutter/material.dart';
import 'package:finc/screens/category/modal%20category/created_category_modal.dart';
import 'package:finc/screens/category/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class CategoryOptionsModal extends StatelessWidget {
  final String userId;

  const CategoryOptionsModal({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FractionallySizedBox(
        heightFactor: 0.5, // Ajuste a altura conforme necessário
        child: ListView(
          children: [
            const Divider(color: Colors.white24),

            // Opção: Pesquisar Categorias
            ListTile(
              leading: const Icon(Icons.search, color: Colors.white),
              title: const Text('Pesquisar Categorias', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);  // Fechar o modal
                // Aqui você pode implementar a busca, se necessário
              },
            ),

            const Divider(color: Colors.white24),

            // Opção: Gerenciar Categorias
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.white),
              title: const Text('Gerenciar Categorias', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);  // Fechar o modal
                // Implementar lógica de gerenciamento de categorias
              },
            ),

            const Divider(color: Colors.white24),

            // Opção: Criar Categoria
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Criar Categoria', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);  // Fechar o modal atual
                _showCreateCategoryModal(context);  // Mostrar o modal de criação
              },
            ),
            
            const Divider(color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // Método para exibir o modal de criação de categoria
  void _showCreateCategoryModal(BuildContext context) {
    // Obtém o tamanho da tela
    final screenHeight = MediaQuery.of(context).size.height;

    // Calcule o fator de altura dinamicamente com base na altura da tela
    // Aqui usamos um valor fixo (0.65) e subtraímos algum valor para dar flexibilidade
    double heightFactor = 0.65;

    // Você pode fazer ajustes dependendo de outras condições ou conteúdo
    if (screenHeight > 700) {
      heightFactor = 0.62; // Mais alto para telas maiores
    } else if (screenHeight < 600) {
      heightFactor = 0.55; // Menor para telas menores
    }

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
            child: FractionallySizedBox(
              heightFactor: heightFactor, // Usando o valor dinâmico aqui
              child: AddCategoryModal(
                onCategoryCreated: () {
                  context.read<GetCategoriesBloc>().add(GetCategories(userId));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
