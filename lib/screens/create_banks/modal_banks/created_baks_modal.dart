import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/create_banks/blocs/bank_bloc.dart';
import 'package:finc/screens/create_banks/blocs/bank_event.dart';
import 'package:finc/screens/create_banks/blocs/bank_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankOptionsModal extends StatefulWidget {
  final String userId;

  const BankOptionsModal({Key? key, required this.userId}) : super(key: key);

  @override
  State<BankOptionsModal> createState() => _BankOptionsModalState();
}

class _BankOptionsModalState extends State<BankOptionsModal> {
  BankEntity? selectedBank;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Carrega bancos ao iniciar o modal
    context.read<BankBloc>().add(LoadBanks(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        if (state is BankLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BankError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (state is BankLoaded) {
          final allBanks = state.banks;
          final filteredBanks = allBanks
              .where((bank) =>
                  bank.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .take(5)
              .toList();

          // Ajusta altura do modal conforme quantidade de itens
          double heightFactor;
          if (filteredBanks.isEmpty) {
            heightFactor = 0.35;
          } else if (filteredBanks.length <= 2) {
            heightFactor = 0.5;
          } else if (filteredBanks.length <= 4) {
            heightFactor = 0.65;
          } else {
            heightFactor = 0.75;
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Column(
                children: [
                  // Campo de busca
                  TextField(
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: 'Pesquisar bancos...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (filteredBanks.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredBanks.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.white24, height: 0.5),
                        itemBuilder: (context, index) {
                          final bank = filteredBanks[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                bank.logo,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image,
                                        color: Colors.white30),
                              ),
                            ),
                            title: Text(
                              bank.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: selectedBank == bank
                                ? const Icon(Icons.check_circle,
                                    color: Colors.greenAccent, size: 18)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedBank = bank;
                              });
                              Navigator.pop(context, bank);
                            },
                          );
                        },
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Nenhum banco encontrado.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),

                  if (allBanks.isNotEmpty) ...[
                    const Divider(color: Colors.white24, height: 0.8),
                    ListTile(
                      leading:
                          const Icon(Icons.manage_accounts, color: Colors.white),
                      title: const Text('Gerenciar Bancos',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navegar para gerenciamento
                      },
                    ),
                    const Divider(color: Colors.white24, height: 0.8),
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.white),
                      title: const Text('Cadastrar Banco',
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navegar para cadastro
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Estado inicial, sem dados
        return const SizedBox.shrink();
      },
    );
  }
}
