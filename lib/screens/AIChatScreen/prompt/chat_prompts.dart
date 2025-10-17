import 'package:expense_repository/expense_repository.dart';

class ChatPrompts {
  /// 🔹 Gasto total por categoria
  static String gastosPorCategoria(String categoria, double total) => """
Analise brevemente:
Categoria: $categoria | Total: R\$${total.toStringAsFixed(2)}
Diga o que representa e dê 2–3 dicas rápidas para equilibrar. Resposta curta.
""";

  /// 🔹 Receita total
  static String receitaTotal(double total) => """
Receita total: R\$${total.toStringAsFixed(2)}.
Explique o que indica e dê 2–3 dicas breves para manter equilíbrio. Resposta curta.
""";

  /// 🔹 Detalhamento de gastos por categoria
  static String gastosDetalhadosPorCategoria(String categoria, List<Expense> despesas) {
    if (despesas.isEmpty) {
      return "Sem gastos em $categoria. Dê 2 dicas rápidas de controle financeiro.";
    }

    final detalhes = despesas.map((e) {
      final data = e.date.toString().split(' ')[0];
      return "- [$data] ${e.description}: R\$${e.amount.toStringAsFixed(2)}";
    }).join("\n");

    final total = despesas.fold<double>(0, (sum, e) => sum + e.amount);

    return """
$categoria | Total: R\$${total.toStringAsFixed(2)} | Itens: ${despesas.length}
$detalhes
Resuma padrões e dê 2–3 dicas curtas para otimizar. Resposta curta.
""";
  }

  /// 🔹 Resumo por categoria
  static String gastosResumoPorCategoria(String categoria, List<Expense> despesas) {
    if (despesas.isEmpty) return "Sem gastos em $categoria.";

    final top = List<Expense>.from(despesas)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final principais = top.take(3).map((e) {
      final data = e.date.toString().split(' ')[0];
      return "- [$data] ${e.description}: R\$${e.amount.toStringAsFixed(2)}";
    }).join("\n");

    final total = despesas.fold<double>(0, (sum, e) => sum + e.amount);

    return """
Resumo $categoria:
Total: R\$${total.toStringAsFixed(2)}
Top gastos:
$principais
Resuma hábitos e dê até 3 dicas breves. Resposta curta.
""";
  }
}
