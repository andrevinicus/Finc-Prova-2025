// get_categories_event.dart
part of 'get_categories_bloc.dart';

abstract class GetCategoriesEvent extends Equatable {
  const GetCategoriesEvent();

  @override
  List<Object> get props => [];
}

class GetCategories extends GetCategoriesEvent {
  final String userId;

  const GetCategories(this.userId);

  @override
  List<Object> get props => [userId];
}

class FilterCategories extends GetCategoriesEvent {
  final String query;
  
  const FilterCategories(this.query);

  @override
  List<Object> get props => [query];
}
