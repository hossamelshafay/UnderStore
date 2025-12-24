import '../models/cart.dart';
import '../../../home/data/models/product_model.dart';

abstract class CartRepo {
  Future<Cart> getCart();
  Future<void> addToCart(ProductModel product, int quantity);
  Future<void> removeFromCart(String itemId);
  Future<void> updateQuantity(String itemId, int quantity);
  Future<void> clearCart();
  Future<int> getCartItemCount();
  Future<bool> isProductInCart(int productId);
}
