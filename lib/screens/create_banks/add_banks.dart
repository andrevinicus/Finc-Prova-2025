import 'dart:convert';
import 'dart:ui';
import 'package:finc/screens/create_banks/constants/banks_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _descricaoController = TextEditingController();
  bool _colorFromModal = false;
  int _color = defaultBanksColors.first;
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

  void _showColorPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: defaultBanksColors.map((colorValue) {
              final isSelected = _color == colorValue;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _color = colorValue;
                    _colorFromModal = true; // ← ativa a reorganização
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Color(colorValue),
                    radius: 22,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  Future<void> fetchBanks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedBanks');
    if (cachedData != null) {
      final banks = json.decode(cachedData) as List<dynamic>;
      final filteredBanks = banks.where((bank) {
        final code = bank['code'].toString();
        return mostUsedBankCodes.contains(code);
      }).toList();
      setState(() {
        allBanks = banks;
        mostUsedBanks = filteredBanks;
        isLoadingBanks = false;
      });
      return; // sai da função porque já carregou do cache
    }
    // Se não tem cache, busca na API
    final url = Uri.parse('https://brasilapi.com.br/api/banks/v1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> banks = json.decode(response.body);
      final filteredBanks = banks.where((bank) {
        final code = bank['code'].toString();
        return mostUsedBankCodes.contains(code);
      }).toList();
      // Salva no cache local para a próxima vez
      await prefs.setString('cachedBanks', response.body);
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 2,
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
                                        height: MediaQuery.of(context).size.height * 0.60,
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
                                              color: const Color.fromARGB(0, 255, 244, 244).withOpacity(0.3),
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
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: const Divider(
                            color: Colors.transparent, 
                            height: 1.5, 
                            thickness: 1.5,
                            ),
                        ),
                        InkWell(
                          onTap: () async {
                            final bank = await showModalBottomSheet(
                              isScrollControlled: false,
                              context: context,
                              builder: (context) => BankOptionsModal(),
                            );
                            if (bank != null) {
                              setState(() {
                                selectedBank = bank;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10, bottom: 15),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: selectedBank == null
                                      ? const Icon(Icons.account_balance, color: Colors.white70, size: 30)
                                      : ClipOval(
                                          child: Image.network(
                                            'https://img.logo.dev/${BankDomains.getDomain(selectedBank!['code'].toString())}?token=pk_TboSWrKJRDKchCKkTSXr3Q',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    selectedBank != null
                                        ? selectedBank!['name']
                                            .replaceAll(RegExp(r'\b(BCO|Bco)\b', caseSensitive: false), '')
                                            .trim()
                                        : 'Selecione uma instituição financeira',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 40, // largura fixa para o ícone, ajusta conforme quiser
                                  child: Transform.translate(
                                    offset: const Offset(-13, 1),
                                    child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: const Divider(
                            color: Colors.white24, 
                            height: 1.5, 
                            thickness: 1.5,
                            ),
                        ),
                         Padding(
                          padding: const EdgeInsets.only( right: 9),
                          child: TextFormField(
                            controller: _descricaoController,
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.words, // para capitalizar a primeira letra de cada palavra
                            cursorColor: Colors.white, // cursor branco
                            selectionControls: MaterialTextSelectionControls(), // mantém comportamento padrão de seleção
                            selectionHeightStyle: BoxHeightStyle.tight,
                            selectionWidthStyle: BoxWidthStyle.tight,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 15, right: 23),
                                child: Icon(Icons.description, color: Colors.white54),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // padding mais equilibrado
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Campo obrigatório' : null,
                          ),
                          
                        ), 
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: const Divider(
                            color: Colors.white24, 
                            height: 1, 
                            thickness: 1.5,
                            ),
                        ),
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cor da Conta', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // lógica para montar a lista com a cor selecionada no modal no topo
                                ...(
                                  _colorFromModal
                                    ? [
                                        _color,
                                        ...defaultBanksColors.where((color) => color != _color),
                                      ]
                                    : defaultBanksColors
                                ).take(5).map((colorValue) {
                                  final isSelected = _color == colorValue;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _color = colorValue;
                                        _colorFromModal = false; // ← NÃO reordena a lista
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: Colors.white, width: 2)
                                            : null,
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Color(colorValue),
                                        radius: 22,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                
                                // botão para abrir o modal
                                GestureDetector(
                                  onTap: () => _showColorPickerModal(context),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 14),
                                    width: 43,
                                    height: 43,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white10,
                                      border: Border.all(color: Colors.white38),
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                        // Espaço entre os bancos mais usados e o campo do banco
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
