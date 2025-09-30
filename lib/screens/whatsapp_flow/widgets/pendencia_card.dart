import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';

class PendenciaCard extends StatelessWidget {
  final AnaliseLancamento lancamento;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails)? onLongPressStart;

  const PendenciaCard({
    super.key,
    required this.lancamento,
    required this.onTap,
    this.onLongPressStart,
  });

  List<String> get missingFields {
    final missing = <String>[];
    if (lancamento.detalhes.isEmpty) missing.add('Detalhes');
    if (lancamento.valorTotal == 0) missing.add('Valor');
    if (lancamento.chatId.isEmpty) missing.add('Chat ID');
    if (lancamento.categoria.isEmpty) missing.add('Categoria');
    if (lancamento.tipo.isEmpty) missing.add('Tipo');
    return missing;
  }

  @override
  Widget build(BuildContext context) {
    final isDespesa = lancamento.tipo.toLowerCase() == 'despesa';
    final hasMissing = missingFields.isNotEmpty;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: GestureDetector(
        onTap: onTap,
        onLongPressStart: onLongPressStart,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                isDespesa ? Icons.arrow_upward : Icons.arrow_downward,
                color: isDespesa ? Colors.red : Colors.green,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      lancamento.detalhes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasMissing)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                lancamento.data.toLocal().toString().split(' ')[0],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Descrição'),
                          content: Text(lancamento.detalhes),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fechar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'R\$ ${lancamento.valorTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDespesa ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: lancamento.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: hasMissing ? Colors.red.shade50 : Colors.green.shade50,
                child: hasMissing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: missingFields
                            .map(
                              (e) => Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    e,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      )
                    : const Text(
                        'Sem pendências',
                        style: TextStyle(color: Colors.green),
                      ),
              ),
              crossFadeState: lancamento.expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
