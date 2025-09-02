class ChatPrompts {
  static String gastosPorCategoria(String categoria, double total) {
    return """
O usuário pediu detalhes sobre seus gastos.
Categoria: $categoria
Total gasto: R\$${total.toStringAsFixed(2)}.

Explique esse gasto de forma clara e amigável e resumido,
dê dicas financeiras e sugestões de como equilibrar as finanças.
""";
  }

  static String receitaTotal(double total) {
    return """
O usuário pediu detalhes sobre sua receita total.
Receita total: R\$${total.toStringAsFixed(2)}.

Responda como um consultor financeiro amigável e resumido,
dê insights sobre o equilíbrio entre receitas e despesas
e sugira boas práticas de finanças pessoais.
""";
  }
}
