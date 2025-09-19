import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:intl/intl.dart';

class AddTransactionModal extends StatefulWidget {
  final Goal goal;
  final void Function(GoalTransaction transaction) onAdd;

  const AddTransactionModal({
    super.key,
    required this.goal,
    required this.onAdd,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;

  final DateFormat _formatter = DateFormat('dd/MM/yyyy');

  Future<void> _pickDate() async {
    // Garante que o initialDate esteja dentro do intervalo
    final now = DateTime.now();
    final initialDate = (_selectedDate ?? now).isBefore(widget.goal.startDate)
        ? widget.goal.startDate
        : (_selectedDate ?? now).isAfter(widget.goal.endDate)
            ? widget.goal.endDate
            : (_selectedDate ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.goal.startDate,
      lastDate: widget.goal.endDate,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _addTransaction() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data.')),
      );
      return;
    }

    final transaction = GoalTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: widget.goal.id,
      amount: amount,
      date: _selectedDate!,
    );

    widget.onAdd(transaction);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adicionar Lançamento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate != null
                    ? _formatter.format(_selectedDate!)
                    : 'Selecionar data',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransaction,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
