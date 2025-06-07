import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/transfer/bloc/transfer_bloc.dart';
import 'package:finc/screens/transfer/bloc/transfer_event.dart';
import 'package:finc/screens/transfer/bloc/transfer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransferBloc(expenseRepository: context.read<ExpenseRepository>()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Nova Transferência', style: TextStyle(color: Colors.black)),
        ),
        body: BlocListener<TransferBloc, TransferState>(
          listener: (context, state) {
            if (state.status == TransferStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transferência realizada com sucesso!')),
              );
              Navigator.of(context).pop();
            } else if (state.status == TransferStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: ${state.errorMessage}')),
              );
            }
          },
          child: const _TransferForm(),
        ),
      ),
    );
  }
}

class _TransferForm extends StatelessWidget {
  const _TransferForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TransferBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<TransferBloc, TransferState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _AccountSelectorTile(
                      label: 'De',
                      account: state.originAccount,
                      onTap: () async {
                        // final result = await showModalBottomSheet<BankAccountEntity>(...);
                        // if (result != null) {
                        //   bloc.add(OriginAccountChanged(result));
                        // }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.swap_horiz, size: 32),
                  ),
                  Expanded(
                    child: _AccountSelectorTile(
                      label: 'Para',
                      account: state.destinationAccount,
                      onTap: () async {
                        // final result = await showModalBottomSheet<BankAccountEntity>(...);
                        // if (result != null) {
                        //   bloc.add(DestinationAccountChanged(result));
                        // }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Valor
          const Text('Valor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.attach_money),
              labelText: 'R\$ 0,00',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => bloc.add(AmountChanged(value)),
          ),
          const SizedBox(height: 24),

          // Descrição
          const Text('Descrição', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.description),
              hintText: 'Ex: Aluguel, cartão...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => bloc.add(DescriptionChanged(value)),
          ),
          const SizedBox(height: 24),

          // Data
          const Text('Data da Transferência', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          BlocBuilder<TransferBloc, TransferState>(
            builder: (context, state) {
              return InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: state.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    bloc.add(DateChanged(pickedDate));
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    state.date != null
                        ? DateFormat('dd/MM/yyyy').format(state.date!)
                        : 'Selecione a data',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          // Botão de Confirmação
          BlocBuilder<TransferBloc, TransferState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isFormValid ? Colors.black : Colors.grey,
                  ),
                  onPressed: state.isFormValid
                      ? () => bloc.add(TransferSubmitted())
                      : null,
                  child: state.status == TransferStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirmar Transferência', style: TextStyle(fontSize: 18)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AccountSelectorTile extends StatelessWidget {
  final String label;
  final BankAccountEntity? account;
  final VoidCallback onTap;

  const _AccountSelectorTile({
    Key? key,
    required this.label,
    required this.account,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: account != null ? Color(account!.colorHex | 0xFF000000) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            account?.logo != null
                ? Image.network(account!.logo!, width: 40, height: 40)
                : const Icon(Icons.account_balance),
            const SizedBox(height: 4),
            Text(
              account?.bankName ?? label,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
