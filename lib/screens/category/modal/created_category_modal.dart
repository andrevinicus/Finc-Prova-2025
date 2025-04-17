import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';


class AddCategoryModal extends StatefulWidget {
  const AddCategoryModal({super.key});

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}
// Fora da classe
const List<int> defaultCategoryColors = [
  0xFF2196F3, // azul
  0xFFE91E63, // rosa
  0xFFFFC107, // amarelo
  0xFF4CAF50, // verde
  0xFF9C27B0, // roxo
  0xFFFF5722, // laranja
  0xFF607D8B, // cinza
  0xFF3F51B5, // azul escuro
  0xFF795548, // marrom
  0xFF009688, // teal
  0xFFCDDC39, // lima
  0xFFFFEB3B, // amarelo claro
  0xFF00BCD4, // ciano
  0xFF8BC34A, // verde limão
  0xFF673AB7, // roxo profundo
  0xFFBDBDBD, // cinza claro
  0xFFBF360C, // marrom queimado
  0xFF4DD0E1, // azul piscina
  0xFF00E676, // verde neon
  0xFFD81B60, // rosa escuro
];
class _AddCategoryModalState extends State<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _icon = 'food'; // Ícone padrão
  int _color = 0xFF2196F3; // Cor padrão
  int _totalExpenses = 0;
  final List<String> _icons = [
    'food',
    'travel',
    'shopping',
    'tech',
    'pet',
    'entertainment',
    'home'
  ];

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child:  FractionallySizedBox(
        heightFactor: 1,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 44, 44, 44),
          body: Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        prefixIcon: Icon(Icons.description, color: Colors.grey[300]),
                        filled: true,
                        fillColor: Colors.white10, // fundo leve dentro do campo
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Escolha um ícone:',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: _icons.map((iconName) {
                        return GestureDetector(
                          onTap: () => setState(() => _icon = iconName),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: _icon == iconName
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Image.asset(
                              'assets/$iconName.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                   const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecione a cor da categoria:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ...defaultCategoryColors.take(5).map((colorValue) {
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
        
                            // Botão "+" para abrir modal
                            GestureDetector(
                              onTap: () => _showColorPickerModal(context),
                              child: Container(
                                margin: const EdgeInsets.only(right: 14),
                                width: 42,
                                height: 42,
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
                      ],
                    ),
        
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
        
                          final newCategory = Category(
                            categoryId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: _name,
                            totalExpenses: _totalExpenses,
                            icon: _icon,
                            color: _color,
                          );
        
                          context
                              .read<CreateCategoryBloc>()
                              .add(CreateCategory(newCategory));
                          Navigator.of(context).pop(); // Fecha o modal
                        }
                      },
                      child: const Text('Criar Categoria'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
