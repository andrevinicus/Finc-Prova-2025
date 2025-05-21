import 'dart:convert';

import 'package:finc/screens/add_expense/views/teclado_numerico.dart';
import 'package:finc/screens/create_banks/constants/banks_domains.dart';
import 'package:flutter/material.dart';
import 'package:finc/screens/create_banks/modal_banks/api_banks.dart';
import 'package:http/http.dart' as http;


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

  List<dynamic> allBanks = [];
  List<dynamic> mostUsedBanks = [];



  bool isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    _amountController.text = '0,00';
    fetchBanks();
  }

  final List<String> mostUsedBankCodes = [
  '104', '237', '341', '260', '623', '756', '380',
];

Future<void> fetchBanks() async {
  final url = Uri.parse('https://brasilapi.com.br/api/banks/v1');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> banks = json.decode(response.body);

    final bankCodes = banks.map((b) => b['code'].toString()).toList();
    print('Códigos retornados pela API: $bankCodes');

    final filteredBanks = banks.where((bank) {
      final code = bank['code'].toString();
      return mostUsedBankCodes.contains(code);
    }).toList();

    print('Bancos filtrados (${filteredBanks.length}):');
    for (var bank in filteredBanks) {
      print('${bank['code']} - ${bank['name']}');
    }

    setState(() {
      allBanks = banks;
      mostUsedBanks = filteredBanks;
      isLoadingBanks = false;
    });
  } else {
    setState(() {
      isLoadingBanks = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao carregar bancos')),
    );
  }
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // tira o foco do teclado
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(141, 31, 30, 30),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(141, 31, 30, 30),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 26),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 2),
              const Text(
                "Nova Conta Bancária",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Parte superior com valor
            GestureDetector(
              onTap: _abrirTecladoNumerico,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                color: const Color(0x8D1F1E1E),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text.replaceAll('.', ',')}',
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

            // Parte inferior com formulário (modal com bordas arredondadas)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 37, 37, 37),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 1,
                            ),
                            itemCount: mostUsedBanks.length + 1,
                            itemBuilder: (context, index) {
                              if (index == mostUsedBanks.length) {
                                // Botão "Outros"
                                return GestureDetector(
                                  onTap: () async {
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
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Center(
                                      child: ClipOval(
                                        child: Container(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 80,
                                          height: 80,
                                          child: const Center(
                                            child: Text(
                                              'Outros',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              // Item de banco
                              final bank = mostUsedBanks[index];
                              final code = bank['code'].toString();
                              final logoUrl =
                                  'https://img.logo.dev/${BankDomains.getDomain(code)}?token=pk_TboSWrKJRDKchCKkTSXr3Q';
                              final isSelected = selectedBank?['code']?.toString() == code;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedBank = bank;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipOval(
                                        child: Container(
                                          color: Colors.white,
                                          width: 80,
                                          height: 80,
                                          child: Image.network(
                                            logoUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.account_balance,
                                              color: Colors.grey,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        IgnorePointer(
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(0.3),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Espaço entre os bancos mais usados e o campo do banco
                        const SizedBox(height: 12),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final valor = double.tryParse(
                                      _amountController.text.replaceAll(',', '.')) ??
                                  0.0;
                              print('Valor: $valor');
                              print('Banco selecionado: ${selectedBank?['name'] ?? 'Nenhum'}');
                              // aqui envia/salva os dados
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
