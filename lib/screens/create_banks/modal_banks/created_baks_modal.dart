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
          // Mantém um tamanho fixo para o loading
          return _buildContainer(
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          );
        }

        if (state is GetBankError) {
          return _buildContainer(
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
          // Filtra os bancos sem limitar a quantidade com take()
          final filteredBanks = allBanks
              .where((bank) =>
                  bank.bankName.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return _buildContainer(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // Faz a coluna se ajustar ao tamanho dos filhos
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  // Flexible permite que o ListView ocupe o espaço restante e se torne rolável
                  Flexible(
                    child: filteredBanks.isNotEmpty
                        ? ListView.separated(
                            // shrinkWrap é importante para o ListView dentro de uma Column com MainAxisSize.min
                            shrinkWrap: true,
                            itemCount: filteredBanks.length,
                            separatorBuilder: (_, __) => const Divider(color: Colors.black12, height: 0.5),
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
                                              const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(Icons.account_balance, color: Colors.grey.shade600, size: 20),
                                      ),
                                title: Text(
                                  bank.bankName,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedBank = bank;
                                  });
                                  Navigator.pop(context, bank);
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'Nenhum banco encontrado.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                  ),
                  // Opções fixas na parte inferior
                  const Divider(color: Colors.black12),
                  ListTile(
                    leading: _circleIcon(Icons.manage_accounts),
                    title: const Text('Gerenciar Banco', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(color: Colors.black12),
                  ListTile(
                    leading: _circleIcon(Icons.add),
                    title: const Text('Cadastrar Banco', style: TextStyle(color: Colors.black87)),
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
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchField() {
    // Seu método _buildSearchField() continua o mesmo
    return SafeArea(
      child: TextField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          hintText: 'Pesquisar bancos...',
          hintStyle: const TextStyle(color: Colors.black45),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  // MÉTODO ATUALIZADO
  Widget _buildContainer({required Widget child}) {
    // Obtém a altura da tela
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Container(
        // Padding interno do modal
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        // Define as restrições de altura
        constraints: BoxConstraints(
          // A altura máxima será 50% da tela
          maxHeight: screenHeight * 0.65,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // O filho agora é diretamente o Column
        child: child,
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    // Seu método _circleIcon() continua o mesmo
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: Icon(icon, color: Colors.black54),
    );
  }
}