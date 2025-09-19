import 'dart:io';

import 'package:expense_repository/expense_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportAndShareCsv(
  List<dynamic> expenses,
  List<dynamic> incomes,
  Map<String, Category> categoryMap,
  int selectedYear, // <-- agora recebemos o ano como parâmetro
) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/Transacoes_$selectedYear.csv';
  final file = File(filePath);

  final csvBuffer = StringBuffer();
  csvBuffer.writeln('Tipo,Data,Categoria,Descrição,Valor');

  // Preenchendo despesas
  for (var tx in expenses) {
    final category = categoryMap[tx.categoryId] ?? Category.empty;
    csvBuffer.writeln(
      'Despesa,${DateFormat('dd/MM/yyyy').format(tx.date)},${category.name},"${tx.description ?? ''}",${tx.amount}'
    );
  }

  // Preenchendo receitas
  for (var tx in incomes) {
    final category = categoryMap[tx.categoryId] ?? Category.empty;
    csvBuffer.writeln(
      'Receita,${DateFormat('dd/MM/yyyy').format(tx.date)},${category.name},"${tx.description ?? ''}",${tx.amount}'
    );
  }

  await file.writeAsString(csvBuffer.toString());

  // Compartilhando arquivo
  await Share.shareXFiles([XFile(filePath)], text: 'Relatório de transações do ano $selectedYear');
}
