import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/category/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_bloc.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_event.dart';
import 'package:finc/screens/whatsapp_flow/bloc/analise_lancamento_state.dart';
import 'package:finc/screens/whatsapp_flow/widgets/dialog_helper.dart';
import 'package:finc/screens/whatsapp_flow/widgets/lancamento_edit_dialog.dart';
import 'package:finc/screens/whatsapp_flow/widgets/pendencia_card.dart';
import 'package:finc/screens/whatsapp_flow/widgets/saldo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  context.read<GetCategoriesBloc>().add(GetCategories(widget.userId)); // 👈 aqui
}


  void _toggleExpanded(AnaliseLancamento lancamento) {
    setState(() {
      lancamento.expanded = !lancamento.expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pendências Financeiras'),
          centerTitle: true,
        ),
        body: BlocBuilder<AnaliseLancamentoBloc, AnaliseLancamentoState>(
          builder: (context, state) {
            if (state is AnaliseLancamentoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnaliseLancamentoLoaded) {
              final saldo = state.lancamentos.fold<double>(
                0.0,
                (prev, element) => element.tipo.toLowerCase() == 'receita'
                    ? prev + element.valorTotal
                    : prev - element.valorTotal,
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
                          onLongPressStart: (details) async {
                            final overlay =
                                Overlay.of(context).context.findRenderObject()
                                    as RenderBox;

                            final action = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromRect(
                                details.globalPosition & const Size(40, 40),
                                Offset.zero & overlay.size,
                              ),
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
                              final categoryState = context.read<GetCategoriesBloc>().state;

                              if (categoryState is GetCategoriesSuccess) {
                                final categorias = categoryState.categories;

                                final updated = await showDialog<AnaliseLancamento>(
                                  context: context,
                                  builder: (_) => LancamentoEditDialog(
                                    lancamento: lanc,
                                    categorias: categorias, // ✅ obrigatório
                                  ),
                                );

                                if (updated != null) {
                                  context.read<AnaliseLancamentoBloc>().add(
                                        UpdateLancamento(
                                          lancamento: updated,
                                          userId: widget.userId,
                                        ),
                                      );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Categorias ainda não carregadas')),
                                );
                              }
                              break;
                              case 'excluir':
                                DialogHelper.showExcluir(context, lanc, () {
                                  context.read<AnaliseLancamentoBloc>().add(
                                        DeleteLancamento(
                                          lancamentoId: lanc.id,
                                          userId: widget.userId,
                                        ),
                                      );
                                });
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
      ),
    );
  }
}
