part of 'search_cubit.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchLoaded extends SearchState {
  final List<ProductModel> products;
  final String query;

  SearchLoaded({required this.products, this.query = ''});
}

final class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}
