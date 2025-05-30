import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // Certifique-se de que esta importação está correta

class TecladoNumerico extends StatefulWidget {
  final String valorInicial;

  const TecladoNumerico({Key? key, required this.valorInicial}) : super(key: key);

  @override
  State<TecladoNumerico> createState() => _TecladoNumericoState();
}

class _TecladoNumericoState extends State<TecladoNumerico> {
  late String valorDigitado;

  @override
  void initState() {
    super.initState();
    valorDigitado = widget.valorInicial;
  }

  void adicionarDigito(String digito) {
    setState(() {
      if (valorDigitado == '0') {
        valorDigitado = digito;
      } else {
        valorDigitado += digito;
      }
    });
  }

  void adicionarVirgula() {
    if (!valorDigitado.contains(',')) {
      setState(() {
        valorDigitado += ',';
      });
    }
  }

  void apagar() {
    setState(() {
      if (valorDigitado.length <= 1) {
        valorDigitado = '0';
      } else {
        valorDigitado = valorDigitado.substring(0, valorDigitado.length - 1);
      }
    });
  }

  void limpar() {
    setState(() {
      valorDigitado = '0';
    });
  }

  void calcular() {
    try {
      String expressao = valorDigitado.replaceAll(',', '.').replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expressao);
      ContextModel cm = ContextModel();
      double resultado = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        // Formata para 2 casas decimais e substitui '.' por ',' para exibição
        valorDigitado = resultado.toStringAsFixed(2).replaceAll('.', ',');
      });
    } catch (e) {
      setState(() {
        valorDigitado = 'Erro';
      });
    }
  }

  Widget _buildNumeroSolto(String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Center(
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.black87, // Alterado para texto mais escuro
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration( // Removido 'const' para permitir colors.grey[200]
        color: Colors.grey[200], // Alterado para um cinza claro
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('R\$', style: TextStyle(fontSize: 18, color: Colors.black54)), // Alterado para texto mais escuro
                Expanded(
                  child: Text(
                    valorDigitado,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black), // Alterado para texto preto
                  ),
                ),
                IconButton(
                  onPressed: apagar,
                  icon: const Icon(Icons.backspace_outlined, color: Colors.grey), // Alterado para ícone cinza
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              ...['7', '8', '9', '÷', '4', '5', '6', '×', '1', '2', '3', '-', ',', '0', '=', '+']
                  .map((e) => _buildNumeroSolto(e, () {
                        if (e == ',') {
                          adicionarVirgula();
                        } else if (e == '=') {
                          calcular();
                        } else {
                          adicionarDigito(e);
                        }
                      })),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54, // Alterado para texto mais escuro
                    side: const BorderSide(color: Colors.grey), // Alterado para borda cinza
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey), // Alterado para ícone cinza
                  label: const Text("Cancelar"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Alterado para azul accent
                    foregroundColor: Colors.white, // Alterado para texto branco
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, valorDigitado),
                  icon: const Icon(Icons.check, color: Colors.white), // Alterado para ícone branco
                  label: const Text("Concluir"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}