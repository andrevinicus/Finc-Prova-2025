import 'package:equatable/equatable.dart';

abstract class GetIncomeEvent extends Equatable {
  const GetIncomeEvent();

  @override
  List<Object> get props => [];
}

class GetIncome extends GetIncomeEvent {
  final String userId;

  const GetIncome(this.userId);

  @override
  List<Object> get props => [userId];
}