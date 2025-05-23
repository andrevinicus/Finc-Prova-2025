import 'package:equatable/equatable.dart';

abstract class GetBankEvent extends Equatable {
  const GetBankEvent();

  @override
  List<Object> get props => [];
}

// Evento para carregar os bancos com o userId
class GetLoadBanks extends GetBankEvent {
  final String userId;

  const GetLoadBanks(this.userId);

  @override
  List<Object> get props => [userId];
}
