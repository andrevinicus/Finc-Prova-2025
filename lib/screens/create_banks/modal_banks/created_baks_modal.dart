import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BankOptionsModal extends StatefulWidget {
  final List<BankEntity> banks;

  const BankOptionsModal({Key? key, required this.banks}) : super(key: key);

  @override
  State<BankOptionsModal> createState() => _BankOptionsModalState();
}

class _BankOptionsModalState extends State<BankOptionsModal> {
  BankEntity? selectedBank;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredBanks = widget.banks
        .where((bank) =>
            bank.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: [
            // Campo de Busca
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
            // Lista de Bancos
            Expanded(
              child: filteredBanks.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum banco encontrado.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredBanks.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Colors.white24,
                        height: 0.5,
                      ),
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
            ),
            const Divider(color: Colors.white24, height: 0.8),
            // Opção: Gerenciar Bancos
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.white),
              title: const Text(
                'Gerenciar Bancos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implemente a navegação para a tela de gerenciamento de bancos
              },
            ),
            const Divider(color: Colors.white24, height: 0.8),
            // Opção: Cadastrar Novo Banco
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text(
                'Cadastrar Banco',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);

              },
            ),
          ],
        ),
      ),
    );
  }
}
