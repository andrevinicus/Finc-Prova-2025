import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_bloc.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_event.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// =====================
/// Componentes Separados
/// =====================

class PendenciaCard extends StatelessWidget {
  final AnaliseLancamento lancamento;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PendenciaCard({
    super.key,
    required this.lancamento,
    required this.onTap,
    required this.onLongPress,
  });

  List<String> get missingFields {
    List<String> missing = [];
    if (lancamento.detalhes.isEmpty) missing.add('Detalhes');
    if (lancamento.valorTotal == 0) missing.add('Valor');
    if (lancamento.chatId.isEmpty) missing.add('Chat ID');
    if (lancamento.categoria.isEmpty) missing.add('Categoria');
    if (lancamento.tipo.isEmpty) missing.add('Tipo');
    return missing;
  }

  @override
  Widget build(BuildContext context) {
    bool isDespesa = lancamento.tipo.toLowerCase() == 'despesa';
    bool hasMissing = missingFields.isNotEmpty;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                isDespesa ? Icons.arrow_upward : Icons.arrow_downward,
                color: isDespesa ? Colors.red : Colors.green,
              ),
              title: Text(lancamento.detalhes),
              subtitle:
                  Text(lancamento.data.toLocal().toString().split(' ')[0]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasMissing)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    'R\$ ${lancamento.valorTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: isDespesa ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold),
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
                color: Colors.red.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: missingFields
                      .map((e) => Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(e, style: const TextStyle(color: Colors.red)),
                            ],
                          ))
                      .toList(),
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

class SaldoCard extends StatelessWidget {
  final double saldo;

  const SaldoCard({super.key, required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Atual',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${saldo.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class DialogHelper {
  static Future<void> showInfo(
      BuildContext context, String title, String descricao) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('$title: $descricao'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  static Future<void> showExcluir(
      BuildContext context, AnaliseLancamento lancamento, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Excluir: ${lancamento.detalhes}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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

/// =====================
/// Tela Principal
/// =====================

class PendenciasScreen extends StatefulWidget {
  final String userId;

  const PendenciasScreen({super.key, required this.userId});

  @override
  State<PendenciasScreen> createState() => _PendenciasScreenState();
}

class _PendenciasScreenState extends State<PendenciasScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnaliseLancamentoBloc>().add(LoadLancamentos(widget.userId));
  }

  void _toggleExpanded(AnaliseLancamento lancamento) {
    setState(() {
      lancamento.expanded = !lancamento.expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendências Financeiras'),
        centerTitle: true,
      ),
      body: BlocBuilder<AnaliseLancamentoBloc, AnaliseLancamentoState>(
        builder: (context, state) {
          if (state is AnaliseLancamentoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnaliseLancamentoLoaded) {
            double saldo = state.lancamentos.fold(
              0.0,
              (prev, element) =>
                  (element.tipo.toLowerCase() == 'receita'
                      ? prev + element.valorTotal
                      : prev - element.valorTotal),
            );

            return Column(
              children: [
                SaldoCard(saldo: saldo),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.lancamentos.length,
                    itemBuilder: (context, index) {
                      final lanc = state.lancamentos[index];
                      return PendenciaCard(
                        lancamento: lanc,
                        onTap: () => _toggleExpanded(lanc),
                        onLongPress: () async {
                          final action = await showMenu<String>(
                            context: context,
                            position: const RelativeRect.fromLTRB(100, 100, 100, 100),
                            items: const [
                              PopupMenuItem(value: 'lancar', child: Text('Lançar')),
                              PopupMenuItem(value: 'editar', child: Text('Editar')),
                              PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                            ],
                          );

                          switch (action) {
                            case 'lancar':
                              DialogHelper.showInfo(context, 'Lançar', lanc.detalhes);
                              break;
                            case 'editar':
                              DialogHelper.showInfo(context, 'Editar', lanc.detalhes);
                              break;
                            case 'excluir':
                              DialogHelper.showExcluir(
                                context,
                                lanc,
                                () => context.read<AnaliseLancamentoBloc>().add(
                                      DeleteLancamento(
                                        lancamentoId: lanc.id,
                                        userId: widget.userId,
                                      ),
                                    ),
                              );
                              break;
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is AnaliseLancamentoError) {
            return Center(child: Text('Erro: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
