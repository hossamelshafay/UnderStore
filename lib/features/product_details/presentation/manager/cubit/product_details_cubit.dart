import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../data/models/details.dart';
import '../../../data/repos/prod_repo.dart';
import '../../../../home/data/models/product_model.dart';
import '../../../../cart/data/repos/cart_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../cart/data/repos/cart_repo_imp.dart';

part 'product_details_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepo orderRepo;
  late CartRepo _cartRepo;

  OrderCubit(this.orderRepo) : super(OrderInitial()) {
    _initializeCartRepo();
  }

  Future<void> _initializeCartRepo() async {
    final prefs = await SharedPreferences.getInstance();
    _cartRepo = CartRepoImp(prefs);
  }

  void loadProductDetail(ProductModel product) {
    emit(ProductDetailLoaded(product: product));
  }

  void updateQuantity(int quantity) {
    final currentState = state;
    if (currentState is ProductDetailLoaded) {
      emit(
        ProductDetailLoaded(
          product: currentState.product,
          selectedQuantity: quantity,
          isFavorite: currentState.isFavorite,
        ),
      );
    }
  }

  void toggleFavorite() {
    final currentState = state;
    if (currentState is ProductDetailLoaded) {
      emit(
        ProductDetailLoaded(
          product: currentState.product,
          selectedQuantity: currentState.selectedQuantity,
          isFavorite: !currentState.isFavorite,
        ),
      );
    }
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    emit(OrderLoading());
    try {
      await _cartRepo.addToCart(product, quantity);
      emit(OrderSuccess('Product added to cart successfully!'));
    } catch (e) {
      emit(OrderError('Failed to add product to cart: $e'));
    }
  }

  Future<void> loadCart() async {
    emit(OrderLoading());
    try {
      final cartItems = await orderRepo.getCartItems();
      final subtotal = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final tax = subtotal * 0.1;
      final shipping = subtotal > 50 ? 0.0 : 5.99;
      final total = subtotal + tax + shipping;

      emit(
        OrderLoaded(
          cartItems: cartItems,
          subtotal: subtotal,
          tax: tax,
          shipping: shipping,
          total: total,
        ),
      );
    } catch (e) {
      emit(OrderError('Failed to load cart: $e'));
    }
  }

  // Future<void> updateCartItemQuantity(String itemId, int quantity) async {
  //   try {
  //     await orderRepo.updateCartItemQuantity(itemId, quantity);
  //     await loadCart(); // Refresh cart
  //   } catch (e) {
  //     emit(OrderError('Failed to update item quantity: $e'));
  //   }
  // }

  // Future<void> removeFromCart(String itemId) async {
  //   try {
  //     await orderRepo.removeFromCart(itemId);
  //     await loadCart(); // Refresh cart
  //   } catch (e) {
  //     emit(OrderError('Failed to remove item: $e'));
  //   }
  // }

  Future<void> createOrder(String shippingAddress) async {
    emit(OrderLoading());
    try {
      final cartItems = await orderRepo.getCartItems();
      if (cartItems.isEmpty) {
        emit(OrderError('Cart is empty'));
        return;
      }

      final order = await orderRepo.createOrder(cartItems, shippingAddress);
      emit(OrderSuccess('Order created successfully!', order: order));
    } catch (e) {
      emit(OrderError('Failed to create order: $e'));
    }
  }
}
