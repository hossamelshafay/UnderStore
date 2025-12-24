import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/details.dart';
import 'prod_repo.dart';

class OrderRepoImp implements OrderRepo {
  final SharedPreferences _prefs;
  static const String _cartKey = 'cart_items';
  static const String _ordersKey = 'user_orders';

  OrderRepoImp(this._prefs);

  @override
  Future<void> addToCart(OrderItem item) async {
    final cartItems = await getCartItems();

    final existingIndex = cartItems.indexWhere(
      (cartItem) => cartItem.product.id == item.product.id,
    );

    if (existingIndex != -1) {
      cartItems[existingIndex] = cartItems[existingIndex].copyWith(
        quantity: cartItems[existingIndex].quantity + item.quantity,
      );
    } else {
      cartItems.add(item);
    }

    await _saveCartItems(cartItems);
  }

  @override
  // Future<void> removeFromCart(String itemId) async {
  //   final cartItems = await getCartItems();
  //   cartItems.removeWhere((item) => item.id == itemId);
  //   await _saveCartItems(cartItems);
  // }
  @override
  // Future<void> updateCartItemQuantity(String itemId, int quantity) async {
  //   final cartItems = await getCartItems();
  //   final index = cartItems.indexWhere((item) => item.id == itemId);
  //   if (index != -1) {
  //     if (quantity <= 0) {
  //       cartItems.removeAt(index);
  //     } else {
  //       cartItems[index] = cartItems[index].copyWith(quantity: quantity);
  //     }
  //     await _saveCartItems(cartItems);
  //   }
  // }
  @override
  Future<List<OrderItem>> getCartItems() async {
    final cartJson = _prefs.getString(_cartKey);
    if (cartJson == null) return [];

    final cartList = json.decode(cartJson) as List;
    return cartList.map((item) => OrderItem.fromJson(item)).toList();
  }

  @override
  // Future<void> clearCart() async {
  //   await _prefs.remove(_cartKey);
  // }
  @override
  Future<Order> createOrder(
    List<OrderItem> items,
    String shippingAddress,
  ) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final userId = _prefs.getString('uid') ?? '';

    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final tax = subtotal * 0.1; // 10% tax
    final shipping = subtotal > 50 ? 0.0 : 5.99; // Free shipping over £50
    final total = subtotal + tax + shipping;

    final order = Order(
      id: orderId,
      userId: userId,
      items: items,
      status: OrderStatus.pending,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      createdAt: DateTime.now(),
      deliveryDate: DateTime.now().add(const Duration(days: 3)),
      shippingAddress: shippingAddress,
      paymentMethod: 'Card',
    );

    // Save order
    await _saveOrder(order);

    // await clearCart();

    return order;
  }

  @override
  Future<List<Order>> getUserOrders(String userId) async {
    final ordersJson = _prefs.getString(_ordersKey);
    if (ordersJson == null) return [];

    final ordersList = json.decode(ordersJson) as List;
    final allOrders = ordersList.map((order) => Order.fromJson(order)).toList();

    return allOrders.where((order) => order.userId == userId).toList();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final orders = await getUserOrders(_prefs.getString('uid') ?? '');
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final ordersJson = _prefs.getString(_ordersKey);
    if (ordersJson == null) return;

    final ordersList = json.decode(ordersJson) as List;
    final orders = ordersList.map((order) => Order.fromJson(order)).toList();

    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {}
  }

  Future<void> _saveCartItems(List<OrderItem> items) async {
    final cartJson = json.encode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(_cartKey, cartJson);
  }

  Future<void> _saveOrder(Order order) async {
    final ordersJson = _prefs.getString(_ordersKey);
    List<Order> orders = [];

    if (ordersJson != null) {
      final ordersList = json.decode(ordersJson) as List;
      orders = ordersList.map((order) => Order.fromJson(order)).toList();
    }

    orders.add(order);

    final updatedOrdersJson = json.encode(
      orders.map((order) => order.toJson()).toList(),
    );
    await _prefs.setString(_ordersKey, updatedOrdersJson);
  }
}
