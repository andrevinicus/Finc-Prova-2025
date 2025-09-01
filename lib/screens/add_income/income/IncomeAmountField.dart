import 'package:flutter/material.dart';
import 'package:finc/screens/add_expense/modals/teclado_numerico.dart';


class IncomeAmountField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const IncomeAmountField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.grey[200],
          builder: (context) => FractionallySizedBox(
            child: TecladoNumerico(
              valorInicial: controller.text.isEmpty
                  ? '0'
                  : controller.text.replaceAll('.', ','),
            ),
          ),
        );

        if (result != null && double.tryParse(result.replaceAll(',', '.')) != null) {
          controller.text = result.replaceAll(',', '.');
          onChanged();
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
              'R\$ ${controller.text.isEmpty ? '0,00' : controller.text.replaceAll('.', ',')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Valor da Receita",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
