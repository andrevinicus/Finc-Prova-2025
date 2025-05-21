import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object> get props => [];
}

// Evento para carregar os bancos com o userId
class LoadBanks extends BankEvent {
  final String userId;

  const LoadBanks(this.userId);

  @override
  List<Object> get props => [userId];
}
