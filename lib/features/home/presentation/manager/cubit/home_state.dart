part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<ProductModel> products;
  final List<String> categories;
  final String selectedCategory;

  HomeLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory = 'All',
  });
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
