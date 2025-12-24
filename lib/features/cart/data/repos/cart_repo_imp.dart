import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../../../home/data/models/product_model.dart';
import 'cart_repo.dart';

class CartRepoImp implements CartRepo {
  final SharedPreferences prefs;
  static const String _cartKey = 'cart_data';

  CartRepoImp(this.prefs);

  @override
  Future<Cart> getCart() async {
    try {
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final Map<String, dynamic> cartData = json.decode(cartJson);
        return Cart.fromJson(cartData);
      }
      return const Cart(items: []);
    } catch (e) {
      return const Cart(items: []);
    }
  }

  @override
  Future<void> addToCart(ProductModel product, int quantity) async {
    try {
      final cart = await getCart();
      final existingItemIndex = cart.items.indexWhere(
        (item) => item.product.id == product.id,
      );

      List<CartItem> updatedItems = [...cart.items];

      if (existingItemIndex >= 0) {
        final existingItem = cart.items[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Add new item
        final newItem = CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          unitPrice: product.price,
          addedAt: DateTime.now(),
        );
        updatedItems.add(newItem);
      }

      final updatedCart = cart.copyWith(items: updatedItems);
      await _saveCart(updatedCart);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    try {
      final cart = await getCart();
      final updatedItems = cart.items
          .where((item) => item.id != itemId)
          .toList();
      final updatedCart = cart.copyWith(items: updatedItems);
      await _saveCart(updatedCart);
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final cart = await getCart();
      final updatedItems = cart.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList();

      final updatedCart = cart.copyWith(items: updatedItems);
      await _saveCart(updatedCart);
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await prefs.remove(_cartKey);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<int> getCartItemCount() async {
    try {
      final cart = await getCart();
      return cart.itemCount;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<bool> isProductInCart(int productId) async {
    try {
      final cart = await getCart();
      return cart.items.any((item) => item.product.id == productId);
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveCart(Cart cart) async {
    final cartJson = json.encode(cart.toJson());
    await prefs.setString(_cartKey, cartJson);
  }
}
