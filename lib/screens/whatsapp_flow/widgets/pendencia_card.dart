import 'package:expense_repository/expense_repository.dart';
import 'package:finc/auth/auth_bloc.dart';
import 'package:finc/auth/auth_state.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_bloc.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finc/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:finc/screens/add_income/blocs/create_expense_bloc/create_income_bloc.dart';

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
    if (lancamento.categoryId.isEmpty) missing.add('Categoria ID');
    if (lancamento.tipo.isEmpty) missing.add('Tipo');
    return missing;
  }

void _lancar(BuildContext context) {
  final authState = context.read<AuthBloc>().state;

  if (authState is! Authenticated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário não logado')),
    );
    return;
  }

  final userId = authState.user.uid;

  final isReceita = lancamento.tipo.toLowerCase() == 'receita';
  final amountValue = lancamento.valorTotal;

  final updatedLancamento = lancamento.copyWith(
    isPending: true, // garante que seja o usuário logado
  );

  if (isReceita) {
    final income = Income(
      id: updatedLancamento.id,
      categoryId: updatedLancamento.categoryId,
      amount: amountValue,
      date: updatedLancamento.data,
      userId: userId,
      type: 'income',
      description: updatedLancamento.detalhes,
      bankId: null,
      imageId: null,
    );

    context.read<CreateIncomeBloc>().add(CreateIncomeSubmitted(income));
  } else {
    final expense = Expense(
      id: updatedLancamento.id,
      categoryId: updatedLancamento.categoryId,
      amount: amountValue,
      date: updatedLancamento.data,
      userId: userId,
      type: 'expense',
      description: updatedLancamento.detalhes,
      bankId: null,
    );

    context.read<CreateExpenseBloc>().add(CreateExpenseSubmitted(expense));
  }

  context.read<AnaliseLancamentoBloc>().add(
        UpdateLancamento(
          lancamento: updatedLancamento,
          userId: userId,
        ),
      );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Lançamento "${updatedLancamento.detalhes}" atualizado como pendente!'),
    ),
  );
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sem pendências',
                            style: TextStyle(color: Colors.green),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(70, 27),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => _lancar(context),
                            child: const Text('Lançar'),
                          ),
                        ],
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
