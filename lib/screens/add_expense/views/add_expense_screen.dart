import 'package:finc/screens/add_expense/views/teclado_numerico.dart';
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
      appBar: AppBar(
        title: const Text("Nova Despesa"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          // Parte superior com valor
          GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FractionallySizedBox(
                  child: TecladoNumerico(
                    valorInicial: _amountController.text.isEmpty
                        ? '0'
                        : _amountController.text.replaceAll('.', ','),
                  ),
                ),
              );

              if (result != null &&
                  double.tryParse(result.replaceAll(',', '.')) != null) {
                _amountController.text = result.replaceAll(',', '.');
                setState(() {});
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text.replaceAll('.', ',')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Valor da despesa",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Parte inferior com formulário
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 85, 82, 82),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Categoria
                      BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                        builder: (context, state) {
                          if (state is GetCategoriesSuccess) {
                            return Column(
                              children: [
                                DropdownButtonFormField<Category>(
                                  decoration: const InputDecoration(
                                    labelText: 'Categoria',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: Colors.white30,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: Colors.white30,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  value: _selectedCategory,
                                  items: state.categories.map((category) {
                                    return DropdownMenuItem<Category>(
                                      value: category,
                                      child: Text(category.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) =>
                                      setState(() => _selectedCategory = value),
                                  validator: (value) => value == null
                                      ? 'Selecione uma categoria'
                                      : null,
                                ),
                                const SizedBox(height: 16),

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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: ListView(
                                            children: [
                                              const Divider(),
                                              ListTile(
                                                leading: const Icon(Icons.search),
                                                title: const Text(
                                                    'Pesquisar Categorias'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  print("Pesquisar Categorias");
                                                },
                                              ),
                                              const Divider(),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.manage_accounts),
                                                title: const Text(
                                                    'Gerenciar Categorias'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  print("Gerenciar Categorias");
                                                },
                                              ),
                                              const Divider(),
                                              ListTile(
                                                leading: const Icon(Icons.add),
                                                title: const Text(
                                                    'Criar Categoria'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                16),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        child: AddCategoryModal(),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const Divider(),
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
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                            ),
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
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Botão salvar
                      BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
                        listener: (context, state) {
                          if (state is CreateExpenseSuccess) {
                            Navigator.pop(context);
                          } else if (state is CreateExpenseFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Erro ao salvar: ${state.message}'),
                              ),
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
                            label: Text(
                                isLoading ? "Salvando..." : "Salvar Despesa"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final expense = Expense(
                                        id: '',
                                        userId: widget.userId,
                                        amount: double.parse(
                                            _amountController.text),
                                        category: _selectedCategory!,
                                        date: _selectedDate,
                                        type: 'despesa',
                                      );
                                      context
                                          .read<CreateExpenseBloc>()
                                          .add(CreateExpenseSubmitted(expense));
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
