import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_event.dart';
import 'package:flutter/material.dart';
import 'package:finc/screens/create_banks/blocs/get_bank/get_bank_bloc.dart';
import 'package:finc/screens/create_banks/modal_banks/created_baks_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class ExpenseBankField extends StatelessWidget {
  final String userId;
  final BankAccountEntity? selectedBank;
  final Function(BankAccountEntity) onBankSelected;

  const ExpenseBankField({
    super.key,
    required this.userId,
    required this.selectedBank,
    required this.onBankSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: const Icon(Icons.account_balance, color: Colors.grey, size: 22),
      title: selectedBank != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        selectedBank!.logo!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      selectedBank!.bankName,
                      style: const TextStyle(color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Selecione um banco',
                style: TextStyle(color: Colors.black54),
              ),
            ),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
      onTap: () async {
        final resultado = await showModalBottomSheet<BankAccountEntity>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.grey[200],
          builder: (BuildContext context) {
            final bankRepository = RepositoryProvider.of<BankRepository>(context);
            return BlocProvider<GetBankBloc>(
              create: (_) => GetBankBloc(bankRepository)..add(GetLoadBanks(userId)),
              child: BankOptionsModal(userId: userId),
            );
          },
        );

        if (resultado != null) {
          onBankSelected(resultado);
        }
      },
    );
  }
}
