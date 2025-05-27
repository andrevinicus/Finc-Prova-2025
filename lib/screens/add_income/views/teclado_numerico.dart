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
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // REMOVIDO: DraggableScrollableSheet
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        // Adicione mainAxisSize.min para que o Column ocupe o mínimo de espaço necessário
        mainAxisSize: MainAxisSize.min, // ESSENCIAL para que o teclado não expanda
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('R\$', style: TextStyle(fontSize: 18, color: Colors.grey)),
                Expanded(
                  child: Text(
                    valorDigitado,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: apagar,
                  icon: const Icon(Icons.backspace_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // REMOVIDO: Expanded em torno do GridView e controller: scrollController
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(), // Mantém a rolagem desativada
            padding: EdgeInsets.zero,
            shrinkWrap: true, // ESSENCIAL para o GridView dentro de um Column com mainAxisSize.min
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
                    foregroundColor: Colors.grey[300],
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Cancelar"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, valorDigitado),
                  icon: const Icon(Icons.check),
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