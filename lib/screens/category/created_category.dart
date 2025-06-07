import 'package:finc/screens/category/constants/category_colors.dart';
import 'package:finc/screens/category/constants/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart'; // Assuming Category is from here
import 'package:finc/screens/category/blocs/create_categorybloc/create_category_bloc.dart';

class AddCategoryModal extends StatefulWidget {
  final VoidCallback? onCategoryCreated;
  final String userId;

  const AddCategoryModal({
    super.key,
    required this.userId,
    this.onCategoryCreated,
  });

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String _name = '';
  String _icon = defaultCategoryIcons.first;
  int _color = defaultCategoryColors.first;
  bool _colorFromModal = false;
  // ignore: unused_field
  int _totalExpenses = 0;
  String _type = 'income'; // Pode ser 'income' ou 'expense'

  @override
  void initState() {
    super.initState();

    _descriptionController.addListener(() {
      final text = _descriptionController.text;
      if (text.isNotEmpty) {
        final firstLetter = text.substring(0, 1);
        final rest = text.substring(1);
        final capitalized = firstLetter.toUpperCase() + rest;
        if (capitalized != text) {
          _descriptionController.value = _descriptionController.value.copyWith(
            text: capitalized,
            selection: TextSelection.collapsed(offset: capitalized.length),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showColorPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: defaultCategoryColors.map((colorValue) {
              final isSelected = _color == colorValue;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _color = colorValue;
                    _colorFromModal = true;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.blueAccent, width: 2)
                        : Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Color(colorValue),
                    radius: 22,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCategoryBloc, CreateCategoryState>(
      listener: (context, state) {
        if (state is CreateCategorySuccess) {
          Navigator.pop(context);
          widget.onCategoryCreated?.call();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            // REMOVIDO: automaticallyImplyLeading: false,
            // REMOVIDO: title: Row( ... )
            // Adicionado um widget vazio para centralizar o conteúdo, se necessário,
            // ou você pode simplesmente remover a AppBar se não precisar de nada nela.
            // Se você quiser um título, pode usar a propriedade `title` diretamente.
            // Para um AppBar completamente vazio, você pode definir `toolbarHeight: 0`
            // ou remover a AppBar inteira.
            // Exemplo para um AppBar vazio (mas ainda presente, para espaçamento):
            toolbarHeight: 0, // Define a altura da AppBar para 0 para removê-la visualmente.
          ),
          body: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _type = 'expense';
                                    print('Tipo selecionado: $_type');
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _type == 'expense' ? Colors.redAccent : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _type == 'expense' ? Colors.redAccent : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    'Despesa',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _type == 'expense' ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _type = 'income';
                                    print('Tipo selecionado: $_type');
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _type == 'income' ? Colors.green : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _type == 'income' ? Colors.green : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    'Receita',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _type == 'income' ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.black87),
                        textCapitalization: TextCapitalization.sentences,
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          labelStyle: const TextStyle(color: Colors.black54),
                          prefixIcon: const Icon(Icons.description, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Escolha um ícone:', style: TextStyle(color: Colors.black87)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: defaultCategoryIcons.map((iconName) {
                          final isSelected = _icon == iconName;
                          return GestureDetector(
                            onTap: () => setState(() => _icon = iconName),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/$iconName.png',
                                width: 20,
                                height: 20,
                                color: isSelected ? Colors.blueAccent : Colors.grey,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cor da Categoria:', style: TextStyle(color: Colors.black87)),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...(
                                  _colorFromModal
                                      ? [
                                            _color,
                                            ...defaultCategoryColors.where((color) => color != _color),
                                          ]
                                      : defaultCategoryColors
                                ).take(5).map((colorValue) {
                                  final isSelected = _color == colorValue;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _color = colorValue;
                                        _colorFromModal = false;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: Colors.blueAccent, width: 2)
                                            : Border.all(color: Colors.grey.shade300, width: 1),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Color(colorValue),
                                        radius: 22,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                GestureDetector(
                                  onTap: () => _showColorPickerModal(context),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 14),
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade100,
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            final category = Category(
                              categoryId: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: _name,
                              icon: _icon,
                              color: _color,
                              type: _type,
                              userId: widget.userId,
                              totalExpenses: 0,
                              createdAt: DateTime.now(),
                            );
                            context.read<CreateCategoryBloc>().add(
                              CreateCategory(category),
                            );
                          }
                        },
                        child: const Text('Adicionar categoria'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}