import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  static Future<void> showInfo(
    BuildContext context,
    String title,
    String descricao,
  ) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('$title: $descricao'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  static Future<void> showExcluir(
    BuildContext context,
    AnaliseLancamento lancamento,
    VoidCallback onConfirm,
  ) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Excluir: ${lancamento.detalhes}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
