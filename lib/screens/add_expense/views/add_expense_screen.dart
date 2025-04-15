
import 'package:finc/screens/category/modal/created_category_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import '../blocs/create_expense_bloc/create_expense_bloc.dart';
import '../blocs/get_categories_bloc/get_categories_bloc.dart';

class AddExpenseScreen extends StatefulWidget {
  final String userId;

  const AddExpenseScreen({super.key, required this.userId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<GetCategoriesBloc>().add(GetCategories(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Despesa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Valor
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Categoria
              BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                builder: (context, state) {
                  if (state is GetCategoriesSuccess) {
                    return Column(
                      children: [
                        // Dropdown de categorias
                        DropdownButtonFormField<Category>(
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCategory,
                          items: state.categories.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          validator: (value) => value == null ? 'Selecione uma categoria' : null,
                        ),
                        const SizedBox(height: 16),
                        // Menu suspenso com as opções
                        ListTile(
                          title: const Text('Opções de Categoria'),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  height: MediaQuery.of(context).size.height * 0.4,// Ajuste a altura do modal conforme necessário
                                  child: ListView(
                                    children: [
                                      const Divider(
                                        color: Color.fromARGB(255, 54, 52, 52), // Cor da barra
                                        thickness: 1, // Espessura da linha
                                        indent: 20, // Espaço da linha da esquerda
                                        endIndent: 20, // Espaço da linha da direita
                                      ),
                                      // Pesquisar Categorias
                                      ListTile(
                                        leading: const Icon(Icons.search),
                                        title: const Text('Pesquisar Categorias'),
                                        onTap: () {
                                          Navigator.pop(context); // Fecha o menu suspenso
                                          print("Pesquisar Categorias");
                                          // Aqui você pode adicionar o código para pesquisar categorias, se necessário
                                        },
                                      ),
                                      const Divider(
                                        color: Color.fromARGB(255, 54, 52, 52), // Cor da barra
                                        thickness: 1, // Espessura da linha
                                        indent: 20, // Espaço da linha da esquerda
                                        endIndent: 20, // Espaço da linha da direita
                                      ),
                                      // Gerenciar Categorias
                                      ListTile(
                                        leading: const Icon(Icons.manage_accounts),
                                        title: const Text('Gerenciar Categorias'),
                                        onTap: () {
                                          Navigator.pop(context); // Fecha o menu suspenso
                                          print("Gerenciar Categorias");
                                          // Aqui você pode adicionar o código para gerenciar categorias, se necessário
                                        },
                                      ),
                                      const Divider(
                                        color: Color.fromARGB(255, 54, 52, 52), // Cor da barra
                                        thickness: 1, // Espessura da linha
                                        indent: 20, // Espaço da linha da esquerda
                                        endIndent: 20, // Espaço da linha da direita
                                      ),
                                      // Adicionar Categoria
                                      ListTile(
                                        leading: const Icon(Icons.add), // Ícone "Adicionar"
                                        title: const Text('Criar Categoria'),
                                        onTap: () {
                                          Navigator.pop(context); // Fecha o menu suspenso
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true, 
                                            builder: (BuildContext context) {
                                              return Container(
                                                padding: const EdgeInsets.all(16),
                                                height: MediaQuery.of(context).size.height * 0.5, 
                                                child: AddCategoryModal(),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      const Divider(
                                        color: Color.fromARGB(255, 54, 52, 52), // Cor da barra
                                        thickness: 1, // Espessura da linha
                                        indent: 20, // Espaço da linha da esquerda
                                        endIndent: 20, // Espaço da linha da direita
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  } else if (state is GetCategoriesLoading) {
                    return const CircularProgressIndicator();
                  } else {
                    return const Text("Erro ao carregar categorias.");
                  }
                },
              ),
              const SizedBox(height: 16),

              // Data
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                  TextButton(
                    child: const Text("Alterar"),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                ],
              ),
              const Spacer(),

              // Botão salvar com BlocConsumer
              BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
                listener: (context, state) {
                  if (state is CreateExpenseSuccess) {
                    Navigator.pop(context); // Fecha a tela ao salvar com sucesso
                  } else if (state is CreateExpenseFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: ${state.message}')),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CreateExpenseLoading;
                  return ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(isLoading ? "Salvando..." : "Salvar Despesa"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final expense = Expense(
                                id: '',
                                userId: widget.userId,
                                amount: double.parse(_amountController.text),
                                category: _selectedCategory!,
                                date: _selectedDate,
                                type: 'despesa',
                              );
                              context.read<CreateExpenseBloc>().add(CreateExpenseSubmitted(expense));
                            }
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
