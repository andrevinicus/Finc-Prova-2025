import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LancamentoEditDialog extends StatefulWidget {
  final AnaliseLancamento lancamento;
  final List<Category> categorias;

  const LancamentoEditDialog({
    super.key,
    required this.lancamento,
    required this.categorias,
  });

  @override
  State<LancamentoEditDialog> createState() => _LancamentoEditDialogState();
}

class _LancamentoEditDialogState extends State<LancamentoEditDialog> {
  late TextEditingController _detalhesController;
  late TextEditingController _valorController;
  late TextEditingController _chatIdController;
  Category? _selectedCategory;
  late String _tipo;
  late DateTime _data;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _detalhesController = TextEditingController(text: widget.lancamento.detalhes);
    _valorController = TextEditingController(text: widget.lancamento.valorTotal.toString());
    _chatIdController = TextEditingController(text: widget.lancamento.chatId);
    _tipo = widget.lancamento.tipo.toLowerCase() == 'receita' ? 'Receita' : 'Despesa';
    _data = widget.lancamento.data;

    // Seleciona a categoria pelo ID, se existir
    if (widget.categorias.isNotEmpty && widget.lancamento.categoryId.isNotEmpty) {
      _selectedCategory = widget.categorias.firstWhere(
        (c) => c.categoryId == widget.lancamento.categoryId.toString(),
        orElse: () => widget.categorias.first,
      );
    } else {
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _detalhesController.dispose();
    _valorController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final updated = widget.lancamento.copyWith(
      detalhes: _detalhesController.text,
      valorTotal: double.tryParse(_valorController.text) ?? 0,
      categoria: _selectedCategory!.name,
      categoryId: _selectedCategory!.categoryId,
      chatId: _chatIdController.text,
      tipo: _tipo,
      data: _data,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        height: size.height * 0.8,
        child: Column(
          children: [
            // Cabeçalho
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              color: Colors.blue,
              child: const Text(
                'Editar Lançamento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Detalhes
                      TextFormField(
                        controller: _detalhesController,
                        decoration: const InputDecoration(
                          labelText: 'Detalhes',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe detalhes' : null,
                      ),
                      const SizedBox(height: 12),

                      // Valor
                      TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor Total',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o valor' : null,
                      ),
                      const SizedBox(height: 12),

                      // Categoria Dropdown
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        items: widget.categorias.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Color(c.color),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (c.icon.isNotEmpty)
                                      Image.asset(
                                        'assets/${c.icon}.png',
                                        width: 16,
                                        height: 16,
                                        color: Colors.white,
                                      )
                                    else
                                      const Icon(
                                        Icons.category,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: const InputDecoration(labelText: 'Categoria'),
                        validator: (v) => v == null ? 'Selecione uma categoria' : null,
                      ),
                      const SizedBox(height: 12),

                      // Chat ID (não editável)
                      TextFormField(
                        controller: _chatIdController,
                        decoration: const InputDecoration(labelText: 'Chat ID'),
                        enabled: false,
                      ),
                      const SizedBox(height: 12),

                      // Tipo (Dropdown)
                      DropdownButtonFormField<String>(
                        value: _tipo,
                        items: const [
                          DropdownMenuItem(
                            value: 'Despesa',
                            child: Text('Despesa'),
                          ),
                          DropdownMenuItem(
                            value: 'Receita',
                            child: Text('Receita'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _tipo = v);
                        },
                        decoration: const InputDecoration(labelText: 'Tipo'),
                      ),
                      const SizedBox(height: 12),

                      // Data
                      Row(
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(_data)),
                          const Spacer(),
                          TextButton(
                            onPressed: _pickDate,
                            child: const Text('Selecionar Data'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botões
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
