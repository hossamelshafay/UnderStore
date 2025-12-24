import 'package:firebase_auth/firebase_auth.dart';
import '../database/repositories/order_db_repository.dart';
import '../database/models/order_db_model.dart';
import '../../features/orders/data/models/order_model.dart';

class OrderSyncService {
  final OrderDatabaseRepository _orderDbRepo = OrderDatabaseRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save order to SQLite
  Future<void> saveOrderToLocal(OrderModel order) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Convert to database model
      final orderDb = OrderDbModel(
        orderId: order.id,
        userId: user.uid,
        totalAmount: order.totalAmount,
        status: order.status.toString().split('.').last,
        paymentMethod: order.paymentMethod.toString().split('.').last,
        deliveryAddress: order.deliveryAddress,
        phoneNumber: order.phoneNumber,
        createdAt: order.createdAt,
      );

      // Convert items
      final itemsDb = order.items.map((item) {
        return OrderItemDbModel(
          orderId: order.id,
          productId: item.product.id.toString(),
          productName: item.product.title,
          productImage: item.product.image,
          price: item.product.price,
          quantity: item.quantity,
        );
      }).toList();

      // Save to database
      await _orderDbRepo.saveOrder(orderDb, itemsDb);
    } catch (e) {
      print('Error saving order to local: $e');
    }
  }

  // Get user orders from SQLite
  Future<List<OrderDbModel>> getLocalOrders() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    return await _orderDbRepo.getUserOrders(user.uid);
  }

  // Get order with items
  Future<Map<String, dynamic>?> getOrderWithItems(String orderId) async {
    final order = await _orderDbRepo.getOrderById(orderId);
    if (order == null) return null;

    final items = await _orderDbRepo.getOrderItems(orderId);

    return {'order': order, 'items': items};
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderDbRepo.updateOrderStatus(orderId, status);
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final ordersCount = await _orderDbRepo.getUserOrdersCount(user.uid);
    final totalSpent = await _orderDbRepo.getUserTotalSpent(user.uid);

    return {'ordersCount': ordersCount, 'totalSpent': totalSpent};
  }

  // Get orders by status
  Future<List<OrderDbModel>> getOrdersByStatus(String status) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    return await _orderDbRepo.getOrdersByStatus(user.uid, status);
  }

  // Clear all orders for current user
  Future<void> clearLocalOrders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final orders = await _orderDbRepo.getUserOrders(user.uid);
    for (var order in orders) {
      await _orderDbRepo.deleteOrder(order.orderId);
    }
  }
}
