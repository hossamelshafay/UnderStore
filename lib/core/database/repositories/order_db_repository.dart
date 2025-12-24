import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/order_db_model.dart';

class OrderDatabaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save order with items
  Future<int> saveOrder(
    OrderDbModel order,
    List<OrderItemDbModel> items,
  ) async {
    final db = await _dbHelper.database;

    // Use transaction to ensure data consistency
    return await db.transaction((txn) async {
      // Insert order
      final orderId = await txn.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert order items
      for (var item in items) {
        await txn.insert(
          'order_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return orderId;
    });
  }

  // Get all orders for a user
  Future<List<OrderDbModel>> getUserOrders(String userId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => OrderDbModel.fromMap(map)).toList();
  }

  // Get order by ID
  Future<OrderDbModel?> getOrderById(String orderId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'orders',
      where: 'orderId = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return OrderDbModel.fromMap(maps.first);
  }

  // Get order items
  Future<List<OrderItemDbModel>> getOrderItems(String orderId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );

    return maps.map((map) => OrderItemDbModel.fromMap(map)).toList();
  }

  // Update order status
  Future<int> updateOrderStatus(String orderId, String status) async {
    final db = await _dbHelper.database;

    return await db.update(
      'orders',
      {'status': status},
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  // Delete order (cascade will delete items)
  Future<int> deleteOrder(String orderId) async {
    final db = await _dbHelper.database;

    return await db.delete(
      'orders',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  // Get orders count for user
  Future<int> getUserOrdersCount(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM orders WHERE userId = ?',
      [userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total spent by user
  Future<double> getUserTotalSpent(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT SUM(totalAmount) as total FROM orders WHERE userId = ? AND status != ?',
      [userId, 'cancelled'],
    );

    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  // Get orders by status
  Future<List<OrderDbModel>> getOrdersByStatus(
    String userId,
    String status,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'orders',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => OrderDbModel.fromMap(map)).toList();
  }

  // Get recent orders (last N orders)
  Future<List<OrderDbModel>> getRecentOrders(String userId, int limit) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return maps.map((map) => OrderDbModel.fromMap(map)).toList();
  }
}
