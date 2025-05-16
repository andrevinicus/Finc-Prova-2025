import 'package:finc/screens/category/constants/category_colors.dart';
import 'package:finc/screens/category/constants/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
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
      backgroundColor: const Color(0xFF1E1E1E),
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
                  setState(() => _color = colorValue);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
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
        child: FractionallySizedBox(
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 44, 44, 44),
            body: Center(
              child: SingleChildScrollView( 
                physics: NeverScrollableScrollPhysics(), // Envolve para evitar overflow na tela
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
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
                                        color: _type == 'expense' ? Colors.red : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Despesa',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _type == 'expense' ? Colors.white : Colors.white60,
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
                                      ),
                                      child: Text(
                                        'Receita',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _type == 'income' ? Colors.white : Colors.white60,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.sentences,
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Descrição',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            prefixIcon: Icon(Icons.description, color: Colors.grey[300]),
                            filled: true,
                            fillColor: const Color.fromARGB(26, 255, 255, 255),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.redAccent.shade700, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.redAccent.shade700, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                          onSaved: (value) => _name = value!,
                        ),

                        const SizedBox(height: 16),
                        const Text('Escolha um ícone:', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children: defaultCategoryIcons.map((iconName) {
                            final isSelected = _icon == iconName;
                            return GestureDetector(
                              onTap: () => setState(() => _icon = iconName),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white10 : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/$iconName.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selecione a cor da categoria:', style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...[
                                    _color,
                                    ...defaultCategoryColors.where((color) => color != _color),
                                  ].take(5).map((colorValue) {
                                    final isSelected = _color == colorValue;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => _color = colorValue);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? Border.all(color: Colors.white, width: 2)
                                              : null,
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
                                      width: 43,
                                      height: 43,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white10,
                                        border: Border.all(color: Colors.white38),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white),
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
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
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
      ),
    );
  }
}
