part of 'cart_cubit.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartLoaded extends CartState {
  final Cart cart;

  CartLoaded({required this.cart});
}

final class CartSuccess extends CartState {
  final String message;
  final Cart cart;

  CartSuccess({required this.message, required this.cart});
}

final class CartError extends CartState {
  final String message;

  CartError(this.message);
}
