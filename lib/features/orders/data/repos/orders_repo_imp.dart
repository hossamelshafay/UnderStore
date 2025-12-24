import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import 'orders_repo.dart';

class OrdersRepoImp implements OrdersRepo {
  final SharedPreferences prefs;
  static const String _ordersKey = 'orders';

  OrdersRepoImp(this.prefs);

  @override
  Future<void> createOrder(OrderModel order) async {
    try {
      final orders = await getOrders();
      orders.add(order);
      final ordersJson = orders.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, jsonEncode(ordersJson));
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final ordersString = prefs.getString(_ordersKey);
      if (ordersString == null || ordersString.isEmpty) {
        return [];
      }

      final ordersJson = jsonDecode(ordersString) as List;
      return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      final orders = await getOrders();
      final orderIndex = orders.indexWhere((o) => o.id == orderId);

      if (orderIndex == -1) {
        throw Exception('Order not found');
      }

      orders[orderIndex] = orders[orderIndex].copyWith(
        status: OrderStatus.cancelled,
      );

      final ordersJson = orders.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, jsonEncode(ordersJson));
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      final orders = await getOrders();
      orders.removeWhere((o) => o.id == orderId);

      final ordersJson = orders.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, jsonEncode(ordersJson));
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}
