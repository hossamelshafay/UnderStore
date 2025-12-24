part of 'product_details_cubit.dart';

@immutable
sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderLoading extends OrderState {}

final class OrderLoaded extends OrderState {
  final List<OrderItem> cartItems;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;

  OrderLoaded({
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
  });
}

final class OrderSuccess extends OrderState {
  final String message;
  final Order? order;

  OrderSuccess(this.message, {this.order});
}

final class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}

final class ProductDetailLoaded extends OrderState {
  final ProductModel product;
  final int selectedQuantity;
  final bool isFavorite;

  ProductDetailLoaded({
    required this.product,
    this.selectedQuantity = 1,
    this.isFavorite = false,
  });
}
