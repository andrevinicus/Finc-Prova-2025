import 'package:expense_repository/expense_repository.dart';

abstract class IncomeRepository {


  Future<void> createIncome(IncomeEntity expense);
  Future<List<IncomeEntity>> getIncomes(String userId);

  Future<List<BankAccountEntity>> fetchBanks(String userId);
  Future<void> createBank(BankAccountEntity bank);
}
