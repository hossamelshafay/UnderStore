import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../data/models/cart.dart';
import '../../../data/repos/cart_repo.dart';
import '../../../../home/data/models/product_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepo cartRepo;

  CartCubit(this.cartRepo) : super(CartInitial());

  Future<void> loadCart() async {
    try {
      emit(CartLoading());
      final cart = await cartRepo.getCart();
      emit(CartLoaded(cart: cart));
    } catch (e) {
      emit(CartError('Failed to load cart: $e'));
    }
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    try {
      await cartRepo.addToCart(product, quantity);
      final cart = await cartRepo.getCart();
      emit(
        CartSuccess(message: 'Item added to cart successfully!', cart: cart),
      );
    } catch (e) {
      emit(CartError('Failed to add item to cart: $e'));
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await cartRepo.removeFromCart(itemId);
      final cart = await cartRepo.getCart();
      emit(CartLoaded(cart: cart));
    } catch (e) {
      emit(CartError('Failed to remove item from cart: $e'));
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(itemId);
        return;
      }
      await cartRepo.updateQuantity(itemId, quantity);
      final cart = await cartRepo.getCart();
      emit(CartLoaded(cart: cart));
    } catch (e) {
      emit(CartError('Failed to update quantity: $e'));
    }
  }

  Future<void> clearCart() async {
    try {
      await cartRepo.clearCart();
      emit(CartLoaded(cart: const Cart(items: [])));
    } catch (e) {
      emit(CartError('Failed to clear cart: $e'));
    }
  }

  Future<int> getCartItemCount() async {
    try {
      return await cartRepo.getCartItemCount();
    } catch (e) {
      return 0;
    }
  }
}
