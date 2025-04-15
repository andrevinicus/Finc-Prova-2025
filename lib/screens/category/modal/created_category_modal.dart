import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddCategoryModal extends StatefulWidget {
  const AddCategoryModal({super.key});

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _icon = 'food'; // Ícone padrão
  int _color = 0xFF2196F3; // Cor padrão
  int _totalExpenses = 0;
  final List<String> _icons = ['food', 'travel', 'shopping', 'tech', 'pet', 'entertainment', 'home'];

  void _showColorPicker() {
    Color pickerColor = Color(_color);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escolha uma cor'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Selecionar'),
            onPressed: () {
              setState(() => _color = pickerColor.value);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Fecha o teclado quando tocar fora
      child: Scaffold(
        body: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: Icon(Icons.description), // Aqui você define o ícone
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 16),
                  const Text('Escolha um ícone:'),
                  Wrap(
                    spacing: 10,
                    children: _icons.map((iconName) {
                      return GestureDetector(
                        onTap: () => setState(() => _icon = iconName),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: _icon == iconName
                                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                : null,
                          ),
                          child: Image.asset('assets/$iconName.png', width: 40, height: 40), // Ajuste no caminho dos assets
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cor selecionada:'),
                      GestureDetector(
                        onTap: _showColorPicker,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(_color),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final newCategory = Category(
                          categoryId: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _name,
                          totalExpenses: _totalExpenses,
                          icon: _icon,
                          color: _color,
                        );

                        context.read<CreateCategoryBloc>().add(CreateCategory(newCategory));
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
    );
  }
}
