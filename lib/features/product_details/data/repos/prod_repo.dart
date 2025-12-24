import '../models/details.dart';

abstract class OrderRepo {
  Future<void> addToCart(OrderItem item);
  // Future<void> removeFromCart(String itemId);
  // Future<void> updateCartItemQuantity(String itemId, int quantity);
  // Future<void> clearCart();
  Future<List<OrderItem>> getCartItems();
  Future<Order> createOrder(List<OrderItem> items, String shippingAddress);
  Future<List<Order>> getUserOrders(String userId);
  Future<Order?> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
