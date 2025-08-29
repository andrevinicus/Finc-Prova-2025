import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';


sealed class GetIncomeState extends Equatable {
  const GetIncomeState();
  
  @override
  List<Object> get props => [];
}

final class GetIncomeInitial extends GetIncomeState {}

final class GetIncomeLoading extends GetIncomeState {}

final class GetIncomeFailure extends GetIncomeState {}

final class GetIncomeSuccess extends GetIncomeState {
  final List<Income> income;

  const GetIncomeSuccess(this.income);

  @override
  List<Object> get props => [income];
}
