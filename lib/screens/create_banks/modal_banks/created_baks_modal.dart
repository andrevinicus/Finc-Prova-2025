import 'package:expense_repository/expense_repository.dart';
import 'package:finc/routes/app_routes.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_bloc.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_event.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankOptionsModal extends StatefulWidget {
  final String userId;

  const BankOptionsModal({Key? key, required this.userId}) : super(key: key);

  @override
  State<BankOptionsModal> createState() => _BankOptionsModalState();
}

class _BankOptionsModalState extends State<BankOptionsModal> {
  BankAccountEntity? selectedBank;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<GetBankBloc>().add(GetLoadBanks(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBankBloc, GetBankState>(
      builder: (context, state) {
        if (state is GetBankLoading) {
          return _buildContainer(
            heightFactor: 0.5,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (state is GetBankError) {
          return _buildContainer(
            heightFactor: 0.35,
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        if (state is GetBankLoaded) {
          final allBanks = state.banks;
          final filteredBanks = allBanks
              .where((bank) => bank.bankName.toLowerCase().contains(searchQuery.toLowerCase()))
              .take(5)
              .toList();

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

          return _buildContainer(
            heightFactor: heightFactor,
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                if (filteredBanks.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredBanks.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 0.5),
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        final isSelected = selectedBank != null && selectedBank!.id == bank.id;

                        return ListTile(
                          leading: bank.logo != null && bank.logo!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    bank.logo!,
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, color: Colors.white30),
                                  ),
                                )
                              : Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.account_balance, color: Colors.white30, size: 20),
                                ),
                          title: Text(
                            bank.bankName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18)
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
                const Divider(color: Colors.white24),
                ListTile(
                  leading: _circleIcon(Icons.manage_accounts),
                  title: const Text('Gerenciar Banco', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: _circleIcon(Icons.add),
                  title: const Text('Cadastrar Banco', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addBanks,
                      arguments: widget.userId,
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink(); // fallback caso estado não esperado
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
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
    );
  }

  Widget _buildContainer({required double heightFactor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white10,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
