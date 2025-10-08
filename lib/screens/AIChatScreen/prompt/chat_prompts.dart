import 'package:expense_repository/expense_repository.dart';

class ChatPrompts {
  /// Detalha o gasto total de uma categoria
  static String gastosPorCategoria(String categoria, double total) {
    return """
O usuário pediu detalhes sobre seus gastos.
Categoria: $categoria
Total gasto: R\$${total.toStringAsFixed(2)}.

Explique esse gasto de forma clara e amigável e resumida,
dê dicas financeiras e sugestões de como equilibrar as finanças.
""";
  }

  /// Mostra a receita total do usuário
  static String receitaTotal(double total) {
    return """
O usuário pediu detalhes sobre sua receita total.
Receita total: R\$${total.toStringAsFixed(2)}.

Responda como um consultor financeiro amigável e resumido,
dê insights sobre o equilíbrio entre receitas e despesas
e sugira boas práticas de finanças pessoais.
""";
  }

  /// Detalha todos os lançamentos de uma categoria (mais detalhado)
  static String gastosDetalhadosPorCategoria(String categoria, List<Expense> despesas) {
    if (despesas.isEmpty) {
      return "Não há gastos registrados na categoria $categoria.";
    }

    final detalhes = despesas.map((e) {
      final descricao = e.description;
      final valor = e.amount.toStringAsFixed(2);
      final data = "[${e.date.toString().split(' ')[0]}]";
      return "- $data $descricao: R\$ $valor";
    }).join("\n");

    return """
O usuário pediu detalhes sobre seus gastos.
Categoria: $categoria
Total de lançamentos: ${despesas.length}
Detalhes dos lançamentos:
$detalhes

Explique esses gastos de forma clara e amigável,
resuma os principais pontos e dê dicas financeiras práticas
para equilibrar as finanças.
""";
  }

  /// Versão resumida: envia menos linhas, apenas os principais lançamentos
  static String gastosResumoPorCategoria(String categoria, List<Expense> despesas) {
    if (despesas.isEmpty) {
      return "Não há gastos registrados na categoria $categoria.";
    }

    // Ordena por valor decrescente e pega até 3 lançamentos
    final topDespesas = List<Expense>.from(despesas)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final principais = topDespesas.take(3).map((e) {
      final data = "[${e.date.toString().split(' ')[0]}]";
      final valor = e.amount.toStringAsFixed(2);
      return "- $data ${e.description}: R\$ $valor";
    }).join("\n");

    final total = despesas.fold<double>(0, (sum, e) => sum + e.amount);

    return """
Categoria: $categoria
Total gasto: R\$${total.toStringAsFixed(2)}
Principais lançamentos:
$principais

Resuma em poucas linhas, explique de forma clara e amigável,
e sugira 2-3 dicas práticas para melhorar as finanças.
""";
  }
}
