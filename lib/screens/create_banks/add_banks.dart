import 'dart:convert';
import 'dart:ui';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_banck_state.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_bank_event.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_banks_blco.dart';
import 'package:finc/screens/create_banks/constants/banks_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finc/screens/add_expense/modals/teclado_numerico.dart';
import 'package:finc/screens/create_banks/constants/banks_domains.dart';
import 'package:flutter/material.dart';
import 'package:finc/screens/create_banks/modal_banks/api_banks.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';


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
      backgroundColor: Colors.white, // Alterado para branco
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                    _colorFromModal = true;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3) // Alterado para preto
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
      return;
    }
    final url = Uri.parse('https://brasilapi.com.br/api/banks/v1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> banks = json.decode(response.body);
      final filteredBanks = banks.where((bank) {
        final code = bank['code'].toString();
        return mostUsedBankCodes.contains(code);
      }).toList();
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
    const Color scaffoldBackgroundColor = Colors.white; // Alterado para branco
    const Color formBackgroundColor = Color(0xFFF2F2F2); // Alterado para cinza claro
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: scaffoldBackgroundColor, // Fundo branco
        appBar: AppBar(
          backgroundColor: scaffoldBackgroundColor, // AppBar também branca
          foregroundColor: Colors.black, // Foreground preto
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
        body: Stack( // Usamos Stack para posicionar o botão fixo
          children: [
            Column(
              children: [
                // Parte superior com valor (usa o fundo do Scaffold)
                GestureDetector(
                  onTap: _abrirTecladoNumerico,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    // Sem cor explícita para este Container, então ele será branco nos cantos
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'R\$ ${_amountController.text.isEmpty ? '0,00' : _amountController.text.replaceAll('.', ',')}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Alterado para preto
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Valor da conta",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54, // Alterado para black54
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Parte inferior com formulário (com bordas arredondadas)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: formBackgroundColor, // Cor específica do formulário
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100), // Adiciona padding para o botão não sobrepor o conteúdo
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
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                                itemCount: mostUsedBanks.length + 1,
                                itemBuilder: (context, index) {
                                  final isOutros = index == mostUsedBanks.length;

                                  if (isOutros) {
                                    return GestureDetector(
                                      onTap: () async {
                                        final result = await showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.white, // Alterado para branco
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
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade400), // Alterado para um cinza mais claro
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              color: Colors.grey.shade200, // Alterado para um cinza claro
                                              child: const Center(
                                                child: Text(
                                                  'Outros',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
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
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade400), // Alterado para cinza mais claro
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              logoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.account_balance,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          IgnorePointer(
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Colors.black.withOpacity(0.3), // Alterado para preto com opacidade
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white, // Alterado para branco
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              )

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
                                  // A condição agora decide qual widget criar
                                  selectedBank == null
                                      // Se nenhum banco for selecionado, mostra o ícone sem borda
                                      ? Container(
                                          width: 35,
                                          height: 35,
                                          child: const Icon(Icons.account_balance, color: Colors.black54, size: 30),
                                        )
                                      // Se um banco for selecionado, mostra a imagem dentro de um container com borda
                                      : Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade400), // A borda fica aqui
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8), // Garante que a imagem tenha cantos arredondados
                                            child: Image.network(
                                              'https://img.logo.dev/${BankDomains.getDomain(selectedBank!['code'].toString())}?token=pk_TboSWrKJRDKchCKkTSXr3Q',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      selectedBank != null
                                          ? selectedBank!['name']
                                              .replaceAll(RegExp(r'\b(BCO|Bco)\b', caseSensitive: false), '')
                                              .trim()
                                          : 'instituição financeira',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Transform.translate(
                                      offset: const Offset(-13, 1),
                                      child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              child: const Divider(
                                color: Colors.black12, // Alterado
                                height: 1.5,
                                thickness: 1.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 9),
                              child: TextFormField(
                                controller: _descricaoController,
                                style: const TextStyle(color: Colors.black), // Alterado
                                textCapitalization: TextCapitalization.words,
                                cursorColor: Colors.black, // Alterado
                                selectionControls: MaterialTextSelectionControls(),
                                selectionHeightStyle: BoxHeightStyle.tight,
                                selectionWidthStyle: BoxWidthStyle.tight,
                                decoration: const InputDecoration( // Use const se tudo dentro for constante
                                  labelText: 'Descrição',
                                  labelStyle: TextStyle(color: Colors.black54), // Alterado
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(left: 15, right: 23),
                                    child: Icon(Icons.description, color: Colors.black54), // Alterado
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  if (value.length < 3) {
                                    return 'A descrição deve ter pelo menos 3 caracteres';
                                  }
                                  if (value.length > 25) { // Exemplo de limite máximo
                                    return 'A descrição não pode ter mais de 50 caracteres';
                                  }
                                  return null; // Retorna null se a validação passar
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: const Divider(
                                color: Colors.black12, // Alterado
                                height: 1,
                                thickness: 1.5,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cor da Conta', style: TextStyle(color: Colors.black)), // Alterado
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
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
                                              _colorFromModal = false;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: isSelected
                                                  ? Border.all(color: Colors.black, width: 2) // Alterado
                                                  : null,
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor: Color(colorValue),
                                              radius: 22,
                                            ),
                                          ),
                                        );
                                      }).toList(),

                                      GestureDetector(
                                        onTap: () => _showColorPickerModal(context),
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 14),
                                          width: 43,
                                          height: 43,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade200, // Alterado
                                            border: Border.all(color: Colors.grey.shade400), // Alterado
                                          ),
                                          child: const Icon(Icons.add, color: Colors.black), // Alterado
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Removido o SizedBox(height: 30) e o ElevatedButton daqui
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: BlocConsumer<AddBankBloc, AddBankState>(
          listener: (context, state) {
            if (state is AddBankSuccess) {
              Navigator.pop(context); // Fecha tela ao salvar com sucesso
            } else if (state is AddBankFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AddBankLoading;

            return FloatingActionButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final amountText = _amountController.text.trim();
                      final amount = double.tryParse(amountText.replaceAll(',', '.'));

                      if (amountText.isEmpty || amount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Informe um valor válido.')),
                        );
                        return;
                      }

                      if (selectedBank == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione um banco.')),
                        );
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        final uuid = Uuid();
                        final userId = FirebaseAuth.instance.currentUser!.uid;

                        final bankName = selectedBank!['name'] as String? ?? '';
                        final bankCode = selectedBank!['code'].toString();
                        final logo = 'https://img.logo.dev/${BankDomains.getDomain(bankCode)}?token=pk_TboSWrKJRDKchCKkTSXr3Q';
                        print('DEBUG: Valor de selectedBank antes de usar!: $selectedBank'); 

                        final bankAccountEntity = BankAccountEntity(
                          id: uuid.v4(),
                          descricao: _descricaoController.text.trim(),
                          bankName: bankName,
                          bankCode: bankCode,
                          logo: logo,
                          initialBalance: amount,
                          colorHex: _color,
                          userId: userId,
                        );

                        // Converter para Model para enviar no evento
                        final bankAccountModel = BankAccountModel.fromEntity(bankAccountEntity);

                        // Dispara evento para salvar banco
                        context.read<AddBankBloc>().add(
                              SubmitNewBank(bankAccountModel),
                            );
                      }
                    },
              backgroundColor: Colors.blueAccent,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.check, size: 30, color: Colors.white), // Adicionado cor para consistência
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


      ),
    );
  }
}