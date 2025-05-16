import 'package:finc/screens/add_expense/views/teclado_numerico.dart';
import 'package:finc/screens/category/modal%20category/option_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import '../blocs/create_expense_bloc/create_expense_bloc.dart';
import '../../category/blocs/get_categories_bloc/get_categories_bloc.dart';

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
    backgroundColor: const Color.fromARGB(255, 20, 20, 20),
    appBar: AppBar(
      title: const Text("Nova Despesa"),
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      foregroundColor: Colors.white,
      elevation: 0,
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
            color: const Color(0xFF121212),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text.replaceAll('.', ',')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Valor da despesa",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
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
              color: Color.fromARGB(255, 37, 37, 37),
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
                    SizedBox(height: 16),
                    Padding(
                      padding:  const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20), // ajuste conforme desejar
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                          TextButton(
                            child: const Text("Alterar", style: TextStyle(color: Colors.white54)),
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
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Divider(
                        color: Colors.white24, 
                        height: 10, 
                        thickness: 1.5,
                        ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1, right: 1),
                      child: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                        builder: (context, state) {
                          if (state is GetCategoriesSuccess) {
                            return Column(
                              children: [
                                ListTile(                          
                                  leading: const Icon(Icons.flag, color: Colors.white54, size: 24),
                                  title: _selectedCategory != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(_selectedCategory!.color),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/${_selectedCategory!.icon}.png',
                                                width: 20,
                                                height: 20,
                                                color: Color(_selectedCategory!.color),
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(width: 12),
                                              Flexible(
                                                child: Text(
                                                  _selectedCategory!.name,
                                                  style: const TextStyle(color: Colors.white70),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                          decoration: BoxDecoration(
                                            // sem borda aqui se quiser, ou com cor neutra
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Opções de Categoria',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        ),
                                      
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                                      onTap: () async {
                                        final resultado = await showModalBottomSheet<Category>(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: const Color(0xFF2C2C2C),
                                          builder: (BuildContext context) {
                                            return CategoryOptionsModal(userId: widget.userId);
                                          },
                                        );
                                      if (resultado != null) {
                                        setState(() {
                                          _selectedCategory = resultado;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              );
                            } else if (state is GetCategoriesLoading) {
                              return const CircularProgressIndicator();
                            } else {
                              return const Text(
                                "Erro ao carregar categorias.",
                                style: TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),
                      ),                    
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Divider(
                          color: Colors.white24, 
                          height: 10, 
                          thickness: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Spacer(),
                      // Botão salvar
                      BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
                        listener: (context, state) {
                          if (state is CreateExpenseSuccess) {
                            Navigator.pop(context);
                          } else if (state is CreateExpenseFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao salvar: ${state.message}'),
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
                            label: Text(isLoading ? "Salvando..." : "Salvar Despesa"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      // Garantir que a categoria selecionada tenha um 'type' válido
                                      final type = _selectedCategory?.type ?? 'expense'; // Pega o 'type' da categoria, ou 'expense' como fallback

                                      final expense = Expense(
                                        id: '',
                                        userId: widget.userId,
                                        amount: double.parse(_amountController.text),
                                        category: _selectedCategory!,
                                        date: _selectedDate,
                                        type: type, // Passa o type da categoria
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
            ),
          ),
        ],
      ),
    );
  }
}