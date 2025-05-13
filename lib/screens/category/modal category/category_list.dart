import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import '../blocs/get_categories_bloc/get_categories_bloc.dart';

class CategoryList extends StatefulWidget {
  final String userId;
  final ValueChanged<Category?> onCategorySelected;

  const CategoryList({Key? key, required this.userId, required this.onCategorySelected}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<GetCategoriesBloc>().add(GetCategories(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
      builder: (context, state) {
        if (state is GetCategoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetCategoriesSuccess) {
          // Filtrando categorias com base no texto digitado
          final filteredCategories = _filterQuery.isEmpty
              ? state.categories
              : state.categories.where((category) => category.name.toLowerCase().contains(_filterQuery.toLowerCase())).toList();

          return Column(
            children: [
              // Campo de pesquisa
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      _filterQuery = query;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar Categorias',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF3A3A3A),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),

              // Lista de categorias filtradas
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return ListTile(
                      leading: Icon(
                        Icons.category,
                        color: Color(category.color),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        widget.onCategorySelected(category);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Text('Erro ao carregar categorias.', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }
}
