import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

// Estados para o BLoC que carrega bancos do usuário
abstract class GetBankState extends Equatable {
  const GetBankState();

  @override
  List<Object?> get props => [];
}

// Estado inicial - nada carregado ainda
class GetBankInitial extends GetBankState {}

// Estado enquanto está carregando os dados
class GetBankLoading extends GetBankState {}

// Estado quando os dados foram carregados com sucesso
class GetBankLoaded extends GetBankState {
  final List<BankAccountEntity> banks;

  const GetBankLoaded(this.banks);

  @override
  List<Object?> get props => [banks];
}

// Estado para erros no carregamento
class GetBankError extends GetBankState {
  final String message;

  const GetBankError(this.message);

  @override
  List<Object?> get props => [message];
}
