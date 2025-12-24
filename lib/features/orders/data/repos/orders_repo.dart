import '../models/order_model.dart';

abstract class OrdersRepo {
  Future<void> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders();
  Future<void> cancelOrder(String orderId);
  Future<void> deleteOrder(String orderId);
}
