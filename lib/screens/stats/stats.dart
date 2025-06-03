import 'package:finc/screens/home/blocs/get_block_expense_income.dart';
import 'package:finc/screens/stats/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatScreen extends StatelessWidget {
  final String userId;

  const StatScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // NOVO: Pegamos as dimensões da tela do dispositivo.
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gráficos Despesas e Receitas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              // Definimos a altura como 55% da altura total da tela.
              // Você pode ajustar este valor (ex: 0.5 para metade, 0.6 para 60%).
              height: screenSize.height * 0.50,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: BlocBuilder<GetFinancialDataBloc, GetFinancialDataState>(
                  builder: (context, state) {
                    if (state is GetFinancialDataLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetFinancialDataFailure) {
                      return const Center(child: Text('Falha ao carregar dados'));
                    } else if (state is GetFinancialDataSuccess) {
                      // NOVO: Envolvemos o MyChart com um SizedBox para controlar a largura.
                      return SizedBox(
                        // NOVO: Definimos a largura como 90% da largura da tela.
                        width: screenSize.width * 1,
                        child: MyChart(
                          expenses: state.expenses,
                          incomes: state.income,
                        ),
                      );
                    } else {
                      context.read<GetFinancialDataBloc>().add(GetFinancialData(userId));
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            // O restante do espaço da tela ficará livre abaixo do card.
          ],
        ),
      ),
    );
  }
}