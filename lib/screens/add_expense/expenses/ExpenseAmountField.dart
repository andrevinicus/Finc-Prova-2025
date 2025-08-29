import 'package:finc/screens/add_expense/modals/teclado_numerico.dart';
import 'package:flutter/material.dart';



class ExpenseAmountField extends StatelessWidget {
  final String amount;
  final Function(String) onAmountChanged;

  const ExpenseAmountField({
    super.key,
    required this.amount,
    required this.onAmountChanged,
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
              valorInicial: amount.isEmpty ? '0' : amount.replaceAll('.', ','),
            ),
          ),
        );

        if (result != null && double.tryParse(result.replaceAll(',', '.')) != null) {
          onAmountChanged(result.replaceAll(',', '.'));
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        color: Colors.white, // mesma cor do topo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'R\$ ${amount.isEmpty ? '0,00' : amount.replaceAll('.', ',')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Valor da Despesa",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
