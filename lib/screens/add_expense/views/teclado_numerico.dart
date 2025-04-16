import 'package:flutter/material.dart';

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

  Widget _buildBotao(String texto, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[200],
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
          padding: const EdgeInsets.symmetric(vertical: 3), // reduz o botão
          textStyle: const TextStyle(
            fontSize: 22, // mantém o tamanho do número
            fontWeight: FontWeight.w500,
          ),
      ),
      onPressed: onPressed,
      child: Text(texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.7,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -4)),
            ],
          ),
          child: Column(
            children: [
              // Visor
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
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: apagar,
                      icon: const Icon(Icons.backspace_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Teclado numérico
              Expanded(
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: 3,
                  childAspectRatio: 2, // mais largo e mais compacto
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    ...['7', '8', '9', '4', '5', '6', '1', '2', '3']
                        .map((e) => _buildBotao(e, () => adicionarDigito(e))),
                    _buildBotao(',', adicionarVirgula),
                    _buildBotao('0', () => adicionarDigito('0')),
                    _buildBotao('Limpar', limpar, color: Colors.red[100]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Ações
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
      },
    );
  }
}
