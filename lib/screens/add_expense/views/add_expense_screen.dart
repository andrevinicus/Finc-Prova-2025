import 'dart:ui';

import 'package:finc/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:finc/screens/add_expense/views/teclado_numerico.dart';
import 'package:finc/screens/category/modal%20category/option_category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import '../../category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:uuid/uuid.dart';


class AddExpenseScreen extends StatefulWidget {
  final String userId;
  

  const AddExpenseScreen({super.key, required this.userId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
  
  
}


class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descricaoController = TextEditingController();
  late final String userId;
  
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _amountController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<GetCategoriesBloc>().add(GetCategories(userId));
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();  // tira o foco de qualquer campo de texto
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(141, 31, 30, 30),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(141, 31, 30, 30),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,  
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 26),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 2),
              const Text(
                "Nova Despesa",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
              color: const Color(0x8D1F1E1E),
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
                  const SizedBox(height: 4),
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
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Colors.teal,
                                        onPrimary: Colors.white,
                                        surface: Colors.grey[900]!,
                                        onSurface: Colors.white70,
                                      ),
                                      dialogBackgroundColor: Colors.grey[850],
                                    ),
                                    child: child!,
                                  );
                                },
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
                                              return CategoryOptionsModal(userId: userId);
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
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 9),
                          child: TextFormField(
                            controller: _descricaoController,
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.words, // para capitalizar a primeira letra de cada palavra
                            cursorColor: Colors.white, // cursor branco
                            selectionControls: MaterialTextSelectionControls(), // mantém comportamento padrão de seleção
                            selectionHeightStyle: BoxHeightStyle.tight,
                            selectionWidthStyle: BoxWidthStyle.tight,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 15, right: 23),
                                child: Icon(Icons.description, color: Colors.white54),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // padding mais equilibrado
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Campo obrigatório' : null,
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


                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      // Remova todo o bottomNavigationBar do Scaffold
          floatingActionButton: BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
          listener: (context, state) {
            if (state is CreateExpenseSuccess) {
              Navigator.pop(context);
            } else if (state is CreateExpenseFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CreateExpenseLoading;

            return FloatingActionButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_amountController.text.isEmpty ||
                          double.tryParse(_amountController.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Informe um valor válido.')),
                        );
                        return;
                      }
                      if (_selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione uma categoria.')),
                        );
                        return;
                      }
                      if (_formKey.currentState!.validate()) {
                        final uuid = Uuid();
                        final userId = FirebaseAuth.instance.currentUser!.uid;

                        final expense = Expense(
                          id: uuid.v4(),
                          category: _selectedCategory!,
                          amount: double.parse(_amountController.text),
                          description: _descricaoController.text,
                          date: _selectedDate,
                          userId: userId,
                          type: 'expense',
                        );

                        context.read<CreateExpenseBloc>().add(
                              CreateExpenseSubmitted(expense),
                            );
                      }
                    },
              backgroundColor: Colors.blueAccent,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.check, size: 30), // ícone do "V"
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
