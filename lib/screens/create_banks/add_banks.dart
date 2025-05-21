import 'package:finc/screens/add_expense/views/teclado_numerico.dart';
import 'package:flutter/material.dart';
import 'package:finc/screens/create_banks/modal_banks/api_banks.dart';


class AddBanksScreen extends StatefulWidget {
  final String userId;

  const AddBanksScreen({super.key, required this.userId});

  @override
  State<AddBanksScreen> createState() => _AddBanksScreenState();
}

class _AddBanksScreenState extends State<AddBanksScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? selectedBank;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = '0,00';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showBankModal(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xfff0f0f0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.95,
        child: const BankOptionsModal(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedBank = result;
      });
    }
  }

  Future<void> _abrirTecladoNumerico() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        child: TecladoNumerico(
        valorInicial: _amountController.text == '0,00'
        ? ''
        : _amountController.text.replaceAll('.', ','),
        ),
      ),
    );

    if (result != null &&
        double.tryParse(result.replaceAll(',', '.')) != null) {
      _amountController.text = result.replaceAll('.', ',');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(141, 31, 30, 30),
      appBar: AppBar(
        title: const Text('Nova Conta Bancária'),
        backgroundColor: const Color.fromARGB(141, 31, 30, 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo do valor com teclado numérico
              GestureDetector(
                onTap: _abrirTecladoNumerico,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0x8D1F1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Valor da conta",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de seleção do banco
              InkWell(
                onTap: () => _showBankModal(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.white70),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedBank != null
                              ? selectedBank!['name']
                              : 'Instituição Bancária',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final valor = double.tryParse(
                            _amountController.text.replaceAll(',', '.')) ??
                        0.0;

                    print('Valor: $valor');
                    print(
                        'Banco selecionado: ${selectedBank?['name'] ?? 'Nenhum'}');

                    // Aqui você pode fazer o envio dos dados, salvamento no banco, etc.
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
